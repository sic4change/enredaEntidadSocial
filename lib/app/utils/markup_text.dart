/// Lightweight inline markup used by the social report text fields.
///
/// Supported syntax (a strict subset of Markdown):
///   * `**text**`  → bold
///   * `*text*`    → italic
///   * `***text***`→ bold + italic
///   * `\*`        → a literal asterisk (only emitted when needed)
///
/// Design goals:
///   * Texts written before this feature existed (plain strings) must render
///     exactly as before. To guarantee that, markers are only recognised when
///     they are "flanking" (an opening marker is followed by a non-space
///     character, a closing marker is preceded by one) and every style opened
///     in a line is closed in that same line. Otherwise the whole line is
///     treated as literal text.
///   * The stored value is still a plain [String], so the data model and
///     Firestore documents do not change.
library markup_text;

/// Style of a single visible character.
class MarkupStyle {
  const MarkupStyle({this.bold = false, this.italic = false});

  final bool bold;
  final bool italic;

  static const MarkupStyle plain = MarkupStyle();

  bool get isPlain => !bold && !italic;

  MarkupStyle copyWith({bool? bold, bool? italic}) =>
      MarkupStyle(bold: bold ?? this.bold, italic: italic ?? this.italic);

  @override
  bool operator ==(Object other) =>
      other is MarkupStyle && other.bold == bold && other.italic == italic;

  @override
  int get hashCode => Object.hash(bold, italic);

  @override
  String toString() => 'MarkupStyle(bold: $bold, italic: $italic)';
}

/// A visible character (UTF-16 code unit) together with its style.
class StyledChar {
  const StyledChar(this.char, this.style);

  final String char;
  final MarkupStyle style;

  bool get isWhitespace => char.trim().isEmpty;

  StyledChar withStyle(MarkupStyle s) => StyledChar(char, s);

  @override
  bool operator ==(Object other) =>
      other is StyledChar && other.char == char && other.style == style;

  @override
  int get hashCode => Object.hash(char, style);
}

/// A run of consecutive visible characters sharing the same style.
class StyledRun {
  const StyledRun(this.text, this.style);

  final String text;
  final MarkupStyle style;
}

/// Result of parsing a raw (stored) string.
class ParsedMarkup {
  ParsedMarkup._({
    required this.raw,
    required this.chars,
    required this.rawIndexOfVisible,
    required this.hiddenRaw,
    required this.styleAtRaw,
  });

  /// The raw string, markers included.
  final String raw;

  /// Visible characters with their style. Newlines are kept as plain chars.
  final List<StyledChar> chars;

  /// For every visible char, its index in [raw].
  final List<int> rawIndexOfVisible;

  /// For every raw index, whether that code unit is a hidden marker.
  final List<bool> hiddenRaw;

  /// Style that applies to text inserted at each raw caret position
  /// (length = raw.length + 1).
  final List<MarkupStyle> styleAtRaw;

  late final String visibleText = chars.map((c) => c.char).join();

  late final bool hasFormatting = chars.any((c) => !c.style.isPlain);

  /// Whether any marker is hidden in [raw].
  late final bool hasHidden = hiddenRaw.contains(true);

  /// Whether the visible text contains a literal `*` (legacy texts, escapes).
  late final bool hasLiteralAsterisk = chars.any((c) => c.char == '*');

  /// Number of visible characters located before the raw [offset].
  int visibleIndexOfRaw(int offset) {
    int count = 0;
    final limit = offset.clamp(0, raw.length);
    for (int i = 0; i < limit; i++) {
      if (!hiddenRaw[i]) count++;
    }
    return count;
  }

  /// Raw caret position that sits right after visible char `visible - 1`
  /// (i.e. *inside* that char's styling), or 0 for the very beginning.
  int rawCaretAfterVisible(int visible) {
    if (visible <= 0) return 0;
    if (visible > rawIndexOfVisible.length) return raw.length;
    return rawIndexOfVisible[visible - 1] + 1;
  }

  /// Raw position of visible char [visible] (i.e. *after* any opening marker).
  int rawCaretBeforeVisible(int visible) {
    if (visible >= rawIndexOfVisible.length) return raw.length;
    if (visible < 0) return 0;
    return rawIndexOfVisible[visible];
  }

  /// Visible text grouped by style, ready to be rendered.
  List<StyledRun> get runs => buildRuns(chars);

  /// Runs for each line (split on `\n`), useful for paragraph-based renderers.
  List<List<StyledRun>> get lineRuns {
    final List<List<StyledRun>> lines = [];
    List<StyledChar> current = [];
    for (final c in chars) {
      if (c.char == '\n') {
        lines.add(buildRuns(current));
        current = [];
      } else {
        current.add(c);
      }
    }
    lines.add(buildRuns(current));
    return lines;
  }
}

List<StyledRun> buildRuns(List<StyledChar> chars) {
  final List<StyledRun> runs = [];
  final buffer = StringBuffer();
  MarkupStyle? current;
  for (final c in chars) {
    if (current != null && c.style != current) {
      runs.add(StyledRun(buffer.toString(), current));
      buffer.clear();
    }
    current = c.style;
    buffer.write(c.char);
  }
  if (current != null && buffer.isNotEmpty) {
    runs.add(StyledRun(buffer.toString(), current));
  }
  return runs;
}

bool _isSpace(String? c) => c == null || c.trim().isEmpty;

/// Quick check used by renderers to keep the legacy code path untouched.
bool mightContainMarkup(String? raw) => raw != null && raw.contains('*');

/// Parses [raw] into visible styled chars plus the raw↔visible mapping.
ParsedMarkup parseMarkup(String raw) {
  final List<StyledChar> chars = [];
  final List<int> rawIndexOfVisible = [];
  final List<bool> hidden = List<bool>.filled(raw.length, false);
  final List<MarkupStyle> styleAt =
      List<MarkupStyle>.filled(raw.length + 1, MarkupStyle.plain);

  int lineStart = 0;
  while (lineStart <= raw.length) {
    int lineEnd = raw.indexOf('\n', lineStart);
    if (lineEnd == -1) lineEnd = raw.length;

    if (!_parseLine(raw, lineStart, lineEnd, true, chars, rawIndexOfVisible,
        hidden, styleAt)) {
      _parseLine(raw, lineStart, lineEnd, false, chars, rawIndexOfVisible,
          hidden, styleAt);
    }

    if (lineEnd < raw.length) {
      // The newline itself: visible, plain.
      chars.add(const StyledChar('\n', MarkupStyle.plain));
      rawIndexOfVisible.add(lineEnd);
      hidden[lineEnd] = false;
      styleAt[lineEnd + 1] = MarkupStyle.plain;
    }
    lineStart = lineEnd + 1;
  }

  return ParsedMarkup._(
    raw: raw,
    chars: chars,
    rawIndexOfVisible: rawIndexOfVisible,
    hiddenRaw: hidden,
    styleAtRaw: styleAt,
  );
}

/// Parses raw[start, end). Returns false (and writes nothing) if the line is
/// not well formed in [formatted] mode, so the caller can retry as literal.
bool _parseLine(
  String raw,
  int start,
  int end,
  bool formatted,
  List<StyledChar> outChars,
  List<int> outRawIndex,
  List<bool> outHidden,
  List<MarkupStyle> outStyleAt,
) {
  final List<StyledChar> chars = [];
  final List<int> rawIdx = [];
  final List<int> hiddenIdx = [];
  // styleAt values for raw positions [start, end], committed on success.
  final List<MarkupStyle> styleAt =
      List<MarkupStyle>.filled(end - start + 1, MarkupStyle.plain);

  bool bold = false;
  bool italic = false;
  

  int i = start;
  while (i < end) {
    final c = raw[i];
    if (formatted && c == '\\' && i + 1 < end && raw[i + 1] == '*') {
      hiddenIdx.add(i);
      final style = MarkupStyle(bold: bold, italic: italic);
      styleAt[i + 1 - start] = style;
      chars.add(StyledChar('*', style));
      rawIdx.add(i + 1);
      i += 2;
      styleAt[i - start] = style;
      continue;
    }
    if (formatted && c == '*') {
      int n = 0;
      while (i + n < end && raw[i + n] == '*') {
        n++;
      }
      if (n <= 3) {
        final bool toggleBold = n >= 2;
        final bool toggleItalic = n != 2;
        final String? prev = i > start ? raw[i - 1] : null;
        final String? next = i + n < end ? raw[i + n] : null;
        bool ok = true;
        if (toggleBold) ok &= bold ? !_isSpace(prev) : !_isSpace(next);
        if (toggleItalic) ok &= italic ? !_isSpace(prev) : !_isSpace(next);
        if (ok) {
          for (int k = 0; k < n; k++) {
            hiddenIdx.add(i + k);
          }
          if (toggleBold) bold = !bold;
          if (toggleItalic) italic = !italic;
          final style = MarkupStyle(bold: bold, italic: italic);
          // Positions strictly inside the marker run inherit the new style,
          // but the caret is snapped out of them by the controller anyway.
          for (int k = 1; k <= n; k++) {
            styleAt[i + k - start] = style;
          }
          i += n;
          continue;
        }
      }
      // Literal asterisks.
      final style = MarkupStyle(bold: bold, italic: italic);
      for (int k = 0; k < n; k++) {
        chars.add(StyledChar('*', style));
        rawIdx.add(i + k);
        styleAt[i + k + 1 - start] = style;
      }
      i += n;
      continue;
    }
    final style = MarkupStyle(bold: bold, italic: italic);
    chars.add(StyledChar(c, style));
    rawIdx.add(i);
    i++;
    styleAt[i - start] = style;
  }

  if (formatted && (bold || italic)) return false;

  outChars.addAll(chars);
  outRawIndex.addAll(rawIdx);
  for (final h in hiddenIdx) {
    outHidden[h] = true;
  }
  for (int k = 0; k < styleAt.length; k++) {
    outStyleAt[start + k] = styleAt[k];
  }
  // The caret at the very end of a line (before the closing markers have been
  // consumed) keeps the style of the last char; after all markers it is plain.
  return true;
}

/// Makes the style of whitespace depend only on its neighbours, so styled
/// runs never start or end with whitespace (required by the flanking rule).
List<StyledChar> normalizeStyles(List<StyledChar> input) {
  final out = List<StyledChar>.of(input);
  int i = 0;
  while (i < out.length) {
    if (out[i].char == '\n') {
      out[i] = out[i].withStyle(MarkupStyle.plain);
      i++;
      continue;
    }
    if (!out[i].isWhitespace) {
      i++;
      continue;
    }
    int j = i;
    while (j < out.length && out[j].isWhitespace && out[j].char != '\n') {
      j++;
    }
    final MarkupStyle? before = i > 0 && out[i - 1].char != '\n'
        ? out[i - 1].style
        : null;
    final MarkupStyle? after =
        j < out.length && out[j].char != '\n' ? out[j].style : null;
    final style = MarkupStyle(
      bold: (before?.bold ?? false) && (after?.bold ?? false),
      italic: (before?.italic ?? false) && (after?.italic ?? false),
    );
    for (int k = i; k < j; k++) {
      out[k] = out[k].withStyle(style);
    }
    i = j;
  }
  return out;
}

/// Serialises styled chars back to the raw stored string.
String serializeMarkup(List<StyledChar> input) {
  final chars = normalizeStyles(input);
  final buffer = StringBuffer();
  List<StyledChar> line = [];
  for (final c in chars) {
    if (c.char == '\n') {
      buffer.write(_serializeLine(line));
      buffer.write('\n');
      line = [];
    } else {
      line.add(c);
    }
  }
  buffer.write(_serializeLine(line));
  return buffer.toString();
}

String _serializeLine(List<StyledChar> line) {
  final hasStyle = line.any((c) => !c.style.isPlain);
  final plain = line.map((c) => c.char).join();
  if (!hasStyle) {
    // Plain line: keep it byte-identical whenever it round-trips.
    if (_sameChars(parseMarkup(plain).chars, line)) return plain;
    return _emit(line, escape: true);
  }
  final unescaped = _emit(line, escape: false);
  if (_sameChars(parseMarkup(unescaped).chars, line)) return unescaped;
  final escaped = _emit(line, escape: true);
  if (_sameChars(parseMarkup(escaped).chars, line)) return escaped;
  // Should never happen; drop formatting rather than corrupt the text.
  return plain;
}

String _emit(List<StyledChar> line, {required bool escape}) {
  final b = StringBuffer();
  MarkupStyle current = MarkupStyle.plain;
  for (final c in line) {
    if (c.style != current) {
      b.write(_toggle(current, c.style));
      current = c.style;
    }
    b.write(escape && c.char == '*' ? r'\*' : c.char);
  }
  b.write(_toggle(current, MarkupStyle.plain));
  return b.toString();
}

String _toggle(MarkupStyle from, MarkupStyle to) {
  final n = (from.bold != to.bold ? 2 : 0) + (from.italic != to.italic ? 1 : 0);
  return '*' * n;
}

bool _sameChars(List<StyledChar> a, List<StyledChar> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// Plain text without markers (e.g. for exports or length checks).
String stripMarkup(String raw) =>
    mightContainMarkup(raw) ? parseMarkup(raw).visibleText : raw;
