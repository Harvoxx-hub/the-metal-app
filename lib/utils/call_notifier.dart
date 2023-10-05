import 'package:flutter/foundation.dart';

class CallNotifier extends ChangeNotifier {
  void call() => notifyListeners();
}
