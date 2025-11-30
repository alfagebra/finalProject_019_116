import 'dart:async';

/// A simple debouncer that delays executing [action] until [delay]
/// has passed without another call. Returns a [Future] that completes
/// after the action finishes. Cancelling a pending debounce will
/// complete the previously returned future immediately.
class Debouncer {
  final Duration delay;
  Timer? _timer;
  Completer<void>? _completer;

  Debouncer({this.delay = const Duration(milliseconds: 300)});

  /// Schedule [action] to run after [delay]. If called again before the
  /// delay expires, the previous scheduled action is cancelled.
  Future<void> run(FutureOr<void> Function() action) {
    // Cancel pending timer and complete its completer so callers don't hang.
    _timer?.cancel();
    if (_completer != null && !_completer!.isCompleted) {
      _completer!.complete();
    }

    _completer = Completer<void>();
    _timer = Timer(delay, () async {
      try {
        final result = action();
        if (result is Future) await result;
        if (!_completer!.isCompleted) _completer!.complete();
      } catch (e, st) {
        if (!_completer!.isCompleted) _completer!.completeError(e, st);
      }
    });

    return _completer!.future;
  }

  /// Cancel pending action and complete the pending future.
  void cancel() {
    _timer?.cancel();
    if (_completer != null && !_completer!.isCompleted) _completer!.complete();
    _timer = null;
    _completer = null;
  }
}
