import 'dart:async';

import 'package:flutter/foundation.dart';

/// End-to-end tracer for anything that touches the Firestore `resources`
/// collection. It is designed to help pinpoint read "leaks" (unexpected
/// subscriptions, duplicated listens, never-cancelled streams) by tagging
/// every subscription with a unique id and logging the full lifecycle:
///
///   📚 [RESOURCES TRACE #id] SUBSCRIBE ...   — caller asked for the stream
///   📚 [RESOURCES TRACE #id] ORIGIN ...      — stack snippet of the caller
///   📚 [RESOURCES TRACE #id] EMIT count=...  — snapshot delivered to consumer
///   📚 [RESOURCES TRACE #id] CANCEL/DONE/ERR — subscription closed
///
/// All methods are no-ops in release builds (guarded by [kDebugMode]) so this
/// is safe to keep enabled in the repository without affecting production.
class ResourcesTracer {
  ResourcesTracer._();

  static int _nextId = 1;

  /// Wraps [source] so every lifecycle event is logged with a dedicated
  /// trace id. Falls back to [source] unchanged in release mode so the
  /// tracer adds no overhead to production builds.
  static Stream<T> traceStream<T>({
    required String op,
    required String path,
    required Stream<T> source,
    Map<String, dynamic>? params,
    int Function(T data)? countOf,
  }) {
    if (!kDebugMode) return source;

    final int id = _nextId++;
    final DateTime startedAt = DateTime.now();

    late final StreamSubscription<T> sub;
    late final StreamController<T> controller;

    void onListenHook() {
      _log('📚 [RESOURCES TRACE #$id] SUBSCRIBE '
          'op=$op path=$path '
          '${_fmtParams(params)} '
          'at=${startedAt.toIso8601String()}');
      final origin = _captureOrigin();
      if (origin != null && origin.isNotEmpty) {
        _log('📚 [RESOURCES TRACE #$id] ORIGIN\n$origin');
      }

      sub = source.listen(
        (data) {
          final int? count = countOf?.call(data);
          _log('📚 [RESOURCES TRACE #$id] EMIT '
              'op=$op '
              '${count != null ? 'count=$count ' : ''}'
              'elapsed=${_elapsed(startedAt)}');
          controller.add(data);
        },
        onError: (Object error, StackTrace st) {
          _log('📚 [RESOURCES TRACE #$id] ERROR '
              'op=$op error=$error '
              'elapsed=${_elapsed(startedAt)}');
          controller.addError(error, st);
        },
        onDone: () {
          _log('📚 [RESOURCES TRACE #$id] DONE '
              'op=$op elapsed=${_elapsed(startedAt)}');
          controller.close();
        },
      );
    }

    controller = StreamController<T>(
      onListen: onListenHook,
      onPause: () {
        _log('📚 [RESOURCES TRACE #$id] PAUSE op=$op');
        sub.pause();
      },
      onResume: () {
        _log('📚 [RESOURCES TRACE #$id] RESUME op=$op');
        sub.resume();
      },
      onCancel: () async {
        _log('📚 [RESOURCES TRACE #$id] CANCEL '
            'op=$op elapsed=${_elapsed(startedAt)}');
        await sub.cancel();
      },
    );

    return controller.stream;
  }

  /// Logs a one-shot read (e.g. `get`, `getCollection`) against the
  /// `resources` collection. Use this for non-stream reads.
  static void logRead({
    required String op,
    required String path,
    int? count,
    Map<String, dynamic>? params,
  }) {
    if (!kDebugMode) return;
    _log('📚 [RESOURCES READ] '
        'op=$op path=$path '
        '${count != null ? 'count=$count ' : ''}'
        '${_fmtParams(params)}');
  }

  /// Logs a write against the `resources` collection (add/update/delete).
  static void logWrite({
    required String op,
    required String path,
    Map<String, dynamic>? params,
  }) {
    if (!kDebugMode) return;
    _log('📚 [RESOURCES WRITE] '
        'op=$op path=$path ${_fmtParams(params)}');
  }

  /// Best-effort capture of the call site that requested this stream. We
  /// skip frames inside the tracer + `database.dart` wrapper so the first
  /// surfaced frame is usually the consumer widget.
  static String? _captureOrigin() {
    try {
      final frames = StackTrace.current.toString().split('\n');
      // Drop this frame + the frames inside the tracer so we land in the
      // caller (usually database.dart -> widget layer).
      return frames
          .skip(1)
          .where((f) => !f.contains('resources_tracer.dart'))
          .take(8)
          .join('\n');
    } catch (_) {
      return null;
    }
  }

  static String _elapsed(DateTime from) {
    return '${DateTime.now().difference(from).inMilliseconds}ms';
  }

  static String _fmtParams(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return '';
    return 'params=$params';
  }

  static void _log(String msg) {
    // ignore: avoid_print
    print(msg);
  }
}
