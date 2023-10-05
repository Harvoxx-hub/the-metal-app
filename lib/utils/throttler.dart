import 'dart:async';
import 'dart:ui';

class Throttler {
  Throttler(this.milliseconds);

  final int milliseconds;
  Timer? _timer;

  void run(VoidCallback action) {
    if (_timer?.isActive ?? false) {
      return;
    }
    action();
    _timer = Timer(Duration(milliseconds: milliseconds), dispose);
  }

  void dispose() {
    _timer?.cancel();
  }
}
