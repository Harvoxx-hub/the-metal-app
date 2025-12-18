import 'dart:async';
import 'dart:ui';

/// Debouncer utility for delaying actions until a pause in activity
///
/// Unlike [Throttler], which runs immediately and ignores subsequent calls,
/// [Debouncer] waits for a pause in activity before running the action.
///
/// Use cases:
/// - Search input: Wait until user stops typing before searching
/// - Auto-save: Wait until user stops editing before saving
/// - Resize handlers: Wait until user stops resizing before recalculating
///
/// Example:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 300);
///
/// void onSearchChanged(String query) {
///   debouncer.run(() {
///     performSearch(query);
///   });
/// }
/// ```
class Debouncer {
  Debouncer({required this.milliseconds});

  /// The delay in milliseconds before running the action
  final int milliseconds;

  Timer? _timer;

  /// Run the action after the debounce delay
  ///
  /// If called again before the delay expires, the timer resets
  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Check if the debouncer is currently waiting
  bool get isActive => _timer?.isActive ?? false;

  /// Cancel any pending action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose of the debouncer and cancel any pending action
  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}
