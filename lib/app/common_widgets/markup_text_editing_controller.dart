import 'package:enreda_empresas/app/utils/markup_text.dart';
import 'package:flutter/material.dart';

/// [TextEditingController] whose [text] stores inline markup
/// (`**bold**`, `*italic*`, see `markup_text.dart`) but renders it as styled
/// text, keeping the markers completely hidden from the user.
///
/// Every edit is applied on the *visible* text and re-serialised, so deleting
/// or typing next to a hidden marker never breaks the formatting.
class MarkupTextEditingController extends TextEditingController {
  MarkupTextEditingController({String? text}) : super(text: text);

  ParsedMarkup? _parsedCache;

  /// Style to apply to the next typed characters at [_pendingOffset]
  /// (set by the B / I buttons with no selection, or to keep a style alive
  /// after typing a space at the end of a styled word).
  MarkupStyle? _pendingStyle;
  int? _pendingOffset;

  ParsedMarkup get parsed {
    final cached = _parsedCache;
    if (cached != null && cached.raw == text) return cached;
    return _parsedCache = parseMarkup(text);
  }

  // ---------------------------------------------------------------------------
  // Rendering
  // ---------------------------------------------------------------------------

  static const TextStyle _hiddenStyle = TextStyle(
    fontSize: 0.01,
    color: Colors.transparent,
    letterSpacing: 0,
    wordSpacing: 0,
    height: 0.01,
  );

  /// Styles indexed by `bold | italic << 1 | composing << 2`; 8 = hidden.
  static const List<TextStyle?> _styles = [
    null,
    TextStyle(fontWeight: FontWeight.w700),
    TextStyle(fontStyle: FontStyle.italic),
    TextStyle(fontWeight: FontWeight.w700, fontStyle: FontStyle.italic),
    TextStyle(decoration: TextDecoration.underline),
    TextStyle(
        fontWeight: FontWeight.w700, decoration: TextDecoration.underline),
    TextStyle(
        fontStyle: FontStyle.italic, decoration: TextDecoration.underline),
    TextStyle(
        fontWeight: FontWeight.w700,
        fontStyle: FontStyle.italic,
        decoration: TextDecoration.underline),
    _hiddenStyle,
  ];

  // Cache of the last span built (EditableText may ask several times per
  // frame with the same value).
  String? _spanText;
  TextRange? _spanComposing;
  TextStyle? _spanStyle;
  TextSpan? _span;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (!text.contains('*')) {
      // No markup at all: identical to a regular TextField, nothing to parse.
      return super.buildTextSpan(
          context: context, style: style, withComposing: withComposing);
    }
    final p = parsed;
    if (!p.hasHidden && !p.hasFormatting) {
      return super.buildTextSpan(
          context: context, style: style, withComposing: withComposing);
    }

    final composing = withComposing && value.isComposingRangeValid
        ? value.composing
        : TextRange.empty;
    if (_span != null &&
        identical(_spanText, p.raw) &&
        _spanComposing == composing &&
        _spanStyle == style) {
      return _span!;
    }

    final raw = p.raw;
    final keys = List<int>.filled(raw.length, 8);
    for (int v = 0; v < p.chars.length; v++) {
      final ms = p.chars[v].style;
      keys[p.rawIndexOfVisible[v]] = (ms.bold ? 1 : 0) | (ms.italic ? 2 : 0);
    }
    if (composing.isValid && !composing.isCollapsed) {
      for (int i = composing.start; i < composing.end && i < raw.length; i++) {
        if (keys[i] != 8) keys[i] |= 4;
      }
    }

    final List<InlineSpan> children = [];
    int runStart = 0;
    for (int i = 1; i <= raw.length; i++) {
      if (i == raw.length || keys[i] != keys[runStart]) {
        children.add(TextSpan(
          text: raw.substring(runStart, i),
          style: _styles[keys[runStart]],
        ));
        runStart = i;
      }
    }

    _spanText = p.raw;
    _spanComposing = composing;
    _spanStyle = style;
    return _span = TextSpan(style: style, children: children);
  }

  // ---------------------------------------------------------------------------
  // Editing
  // ---------------------------------------------------------------------------

  @override
  set value(TextEditingValue newValue) {
    final old = super.value;

    if (newValue.text == old.text) {
      if (newValue.selection != old.selection) {
        if (_pendingOffset != newValue.selection.baseOffset ||
            !newValue.selection.isCollapsed) {
          _clearPending();
        }
        newValue = newValue.copyWith(
          selection: _snapSelection(newValue.selection, old.selection),
        );
      }
      super.value = newValue;
      return;
    }

    // Programmatic replacement of the whole text (e.g. loading a report).
    if (newValue.text.isEmpty ||
        (!old.selection.isValid && !newValue.selection.isValid)) {
      _clearPending();
      super.value = newValue;
      return;
    }

    if (_isSafeSimpleEdit(old, newValue)) {
      super.value = newValue;
      return;
    }

    final fixed = _applyEdit(old, newValue);
    if (fixed == null) {
      super.value = newValue;
      return;
    }
    if (fixed.text == newValue.text) {
      // Same result as the naive edit: keep the framework value (preserves the
      // IME composing region) but use our caret if it differs.
      super.value = newValue.selection == fixed.selection
          ? newValue
          : newValue.copyWith(selection: fixed.selection);
    } else {
      super.value = fixed;
    }
  }

  @override
  set text(String newText) {
    _clearPending();
    super.value = TextEditingValue(text: newText);
  }

  void _clearPending() {
    _pendingStyle = null;
    _pendingOffset = null;
  }

  static bool _isPlainChar(String c) => c != '*' && c != '\\' && c != '\n';

  /// True for the common case of typing or deleting one ordinary character
  /// away from hidden markers: the raw edit is already correct, so it can be
  /// accepted as is without re-parsing and re-serialising the whole text.
  bool _isSafeSimpleEdit(TextEditingValue old, TextEditingValue nv) {
    if (_pendingStyle != null) return false;
    final sel = old.selection;
    final newSel = nv.selection;
    if (!sel.isValid || !sel.isCollapsed || !newSel.isValid ||
        !newSel.isCollapsed) {
      return false;
    }
    final oldText = old.text;
    final List<bool> hidden;
    if (!oldText.contains('*')) {
      hidden = List<bool>.filled(oldText.length, false);
    } else {
      final p = parsed.raw == oldText ? parsed : parseMarkup(oldText);
      if (p.hasLiteralAsterisk) return false;
      hidden = p.hiddenRaw;
    }
    final newText = nv.text;
    final len = oldText.length;
    final o = sel.baseOffset;
    bool visibleAt(int i) => i < 0 || i >= len || !hidden[i];

    if (newText.length > len) {
      // Insertion at the caret.
      final k = newText.length - len;
      if (newSel.baseOffset != o + k) return false;
      final ins = newText.substring(o, o + k);
      if (!newText.startsWith(oldText.substring(0, o)) ||
          !newText.endsWith(oldText.substring(o))) {
        return false;
      }
      for (int i = 0; i < ins.length; i++) {
        if (!_isPlainChar(ins[i])) return false;
      }
      // Never inside a marker run or between an escape and its asterisk.
      if (!visibleAt(o - 1) && !visibleAt(o)) return false;
      if (o > 0 && hidden[o - 1] && oldText[o - 1] == '\\') return false;
      // Whitespace next to a marker would break the flanking rule.
      if (ins.trim().length != ins.length || ins.trim().isEmpty) {
        if (!visibleAt(o - 1) || !visibleAt(o)) return false;
      }
      return true;
    }

    if (newText.length == len - 1) {
      // Backspace (removes o-1) or forward delete (removes o).
      final int r;
      if (newSel.baseOffset == o - 1) {
        r = o - 1;
      } else if (newSel.baseOffset == o) {
        r = o;
      } else {
        return false;
      }
      if (r < 0 || r >= len) return false;
      if (hidden[r] || !_isPlainChar(oldText[r])) return false;
      if (!visibleAt(r - 1) || !visibleAt(r + 1)) return false;
      return newText == oldText.substring(0, r) + oldText.substring(r + 1);
    }
    return false;
  }

  /// Translates a raw edit into an edit on the visible styled text.
  TextEditingValue? _applyEdit(TextEditingValue old, TextEditingValue nv) {
    final oldText = old.text;
    final newText = nv.text;
    final p = parsed.raw == oldText ? parsed : parseMarkup(oldText);

    // Locate the edit: [start, oldEnd) in old text replaced by `inserted`.
    int start, oldEnd;
    String inserted;
    final sel = old.selection;
    final newCaret = nv.selection.isValid ? nv.selection.extentOffset : -1;
    if (sel.isValid &&
        newCaret >= sel.start &&
        newText.length - (oldText.length - sel.end) == newCaret &&
        newText.startsWith(oldText.substring(0, sel.start)) &&
        newText.endsWith(oldText.substring(sel.end)) &&
        (!sel.isCollapsed || newCaret > sel.start)) {
      // Typing / pasting over the selection.
      start = sel.start;
      oldEnd = sel.end;
      inserted = newText.substring(start, newCaret);
    } else {
      int prefix = 0;
      final minLen =
          oldText.length < newText.length ? oldText.length : newText.length;
      while (prefix < minLen && oldText[prefix] == newText[prefix]) {
        prefix++;
      }
      if (newCaret >= 0 && prefix > newCaret) prefix = newCaret;
      int suffix = 0;
      while (suffix < minLen - prefix &&
          oldText[oldText.length - 1 - suffix] ==
              newText[newText.length - 1 - suffix]) {
        suffix++;
      }
      start = prefix;
      oldEnd = oldText.length - suffix;
      inserted = newText.substring(prefix, newText.length - suffix);
    }

    int vStart = p.visibleIndexOfRaw(start);
    int vEnd = p.visibleIndexOfRaw(oldEnd);

    if (vStart == vEnd && inserted.isEmpty) {
      // Only hidden markers were removed (backspace/delete next to a marker):
      // remove the adjacent visible character instead.
      final bool isBackspace =
          sel.isCollapsed && sel.baseOffset == oldEnd && oldEnd > start;
      if (isBackspace) {
        if (vStart == 0) return old;
        vStart -= 1;
      } else {
        if (vEnd >= p.chars.length) return old;
        vEnd += 1;
      }
    }

    // Style for the inserted characters.
    MarkupStyle insertStyle;
    if (_pendingStyle != null && _pendingOffset == start && vStart == vEnd) {
      insertStyle = _pendingStyle!;
    } else if (vEnd > vStart) {
      insertStyle = p.chars[vStart].style;
    } else {
      insertStyle = p.styleAtRaw[start.clamp(0, p.raw.length)];
    }

    // Pasted text that already carries valid markup keeps its formatting.
    List<StyledChar> insChars;
    if (inserted.length > 1 && mightContainMarkup(inserted)) {
      final pi = parseMarkup(inserted);
      insChars = pi.hasFormatting
          ? pi.chars
          : inserted.split('').map((c) => StyledChar(c, insertStyle)).toList();
    } else {
      insChars =
          inserted.split('').map((c) => StyledChar(c, insertStyle)).toList();
    }

    final model = <StyledChar>[
      ...p.chars.sublist(0, vStart),
      ...insChars,
      ...p.chars.sublist(vEnd),
    ];
    final raw = serializeMarkup(model);
    final np = parseMarkup(raw);
    _parsedCache = np;

    // Keep the caret inside the style of the char just before it.
    final visCaret = vStart + insChars.length;
    final caret = np.rawCaretAfterVisible(visCaret);
    // A typed space at the edge of a styled word is normalised to plain; keep
    // the style alive for the next typed character.
    if (insChars.isNotEmpty &&
        !insertStyle.isPlain &&
        np.chars[visCaret - 1].style != insertStyle) {
      _pendingStyle = insertStyle;
      _pendingOffset = caret;
    } else {
      _clearPending();
    }

    return TextEditingValue(
      text: raw,
      selection: TextSelection.collapsed(offset: caret),
      composing: TextRange.empty,
    );
  }

  /// Keeps a collapsed caret out of the middle of hidden marker runs.
  TextSelection _snapSelection(TextSelection sel, TextSelection oldSel) {
    if (!sel.isValid || !sel.isCollapsed) return sel;
    final p = parsed;
    int o = sel.baseOffset;
    bool inside(int x) =>
        x > 0 && x < p.raw.length && p.hiddenRaw[x - 1] && p.hiddenRaw[x];
    if (!inside(o)) return sel;
    final movingLeft = oldSel.isValid && oldSel.baseOffset > o;
    if (movingLeft) {
      while (inside(o)) {
        o--;
      }
    } else {
      while (inside(o)) {
        o++;
      }
    }
    return TextSelection.collapsed(offset: o, affinity: sel.affinity);
  }

  // ---------------------------------------------------------------------------
  // Formatting commands (used by the floating toolbar and shortcuts)
  // ---------------------------------------------------------------------------

  bool isBoldActive() => _isActive((s) => s.bold);

  bool isItalicActive() => _isActive((s) => s.italic);

  bool _isActive(bool Function(MarkupStyle) get) {
    final sel = selection;
    if (!sel.isValid) return false;
    final hasMarkers = text.contains('*');
    if (!hasMarkers && _pendingStyle == null) return false;
    final p = parsed;
    if (sel.isCollapsed) {
      if (_pendingStyle != null && _pendingOffset == sel.baseOffset) {
        return get(_pendingStyle!);
      }
      return get(p.styleAtRaw[sel.baseOffset.clamp(0, p.raw.length)]);
    }
    final vs = p.visibleIndexOfRaw(sel.start);
    final ve = p.visibleIndexOfRaw(sel.end);
    final relevant =
        p.chars.sublist(vs, ve).where((c) => !c.isWhitespace).toList();
    return relevant.isNotEmpty && relevant.every((c) => get(c.style));
  }

  void toggleBold() => _toggle(
        (s) => s.bold,
        (s, v) => s.copyWith(bold: v),
      );

  void toggleItalic() => _toggle(
        (s) => s.italic,
        (s, v) => s.copyWith(italic: v),
      );

  void _toggle(
    bool Function(MarkupStyle) get,
    MarkupStyle Function(MarkupStyle, bool) set,
  ) {
    final sel = selection;
    if (!sel.isValid) return;
    final p = parsed;

    if (sel.isCollapsed) {
      final current = (_pendingStyle != null &&
              _pendingOffset == sel.baseOffset)
          ? _pendingStyle!
          : p.styleAtRaw[sel.baseOffset.clamp(0, p.raw.length)];
      _pendingStyle = set(current, !get(current));
      _pendingOffset = sel.baseOffset;
      notifyListeners();
      return;
    }

    final vs = p.visibleIndexOfRaw(sel.start);
    final ve = p.visibleIndexOfRaw(sel.end);
    if (ve <= vs) return;
    final relevant =
        p.chars.sublist(vs, ve).where((c) => !c.isWhitespace).toList();
    if (relevant.isEmpty) return;
    final newValue = !relevant.every((c) => get(c.style));

    final model = List<StyledChar>.of(p.chars);
    for (int i = vs; i < ve; i++) {
      if (model[i].char == '\n') continue;
      model[i] = model[i].withStyle(set(model[i].style, newValue));
    }
    final raw = serializeMarkup(model);
    final np = parseMarkup(raw);
    _parsedCache = np;
    _clearPending();
    super.value = TextEditingValue(
      text: raw,
      selection: TextSelection(
        baseOffset: np.rawCaretBeforeVisible(vs),
        extentOffset: np.rawCaretAfterVisible(ve),
      ),
    );
  }
}
