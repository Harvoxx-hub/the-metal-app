import 'dart:math';

import 'package:flutter/widgets.dart';

typedef KeyboardChangeListener = Function(bool isVisible);

/// Keyboard visibility observer that detects keyboard without any plugins.
// ignore: prefer_mixin
class KeyboardListener with WidgetsBindingObserver {
  KeyboardListener() {
    _init();
  }

  static final Random _random = Random();

  final Map<String, KeyboardChangeListener> _changeListeners = {};

  bool get isVisibleKeyboard =>
      (WidgetsBinding.instance.window.viewInsets.bottom) > 0;

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _changeListeners.clear();
  }

  @override
  void didChangeMetrics() {
    _listener();
  }

  String addListener({
    required KeyboardChangeListener onChange,
    String? id,
  }) {
    id ??= _generateId();
    _changeListeners[id] = onChange;

    return id;
  }

  void removeChangeListener(KeyboardChangeListener listener) {
    _removeListener(_changeListeners, listener);
  }

  void removeAtChangeListener(String id) {
    _removeAtListener(_changeListeners, id);
  }

  void removeAtShowListener(String id) {
    _removeAtListener(_changeListeners, id);
  }

  void removeAtHideListener(String id) {
    _removeAtListener(_changeListeners, id);
  }

  void _removeAtListener(Map<String, Function> listeners, String id) {
    listeners.remove(id);
  }

  void _removeListener(Map<String, Function> listeners, Function listener) {
    listeners.removeWhere((key, value) => value == listener);
  }

  String _generateId() {
    return _random.nextDouble().toString();
  }

  void _init() {
    WidgetsBinding.instance.addObserver(this);
  }

  void _listener() {
    if (isVisibleKeyboard) {
      _onChange(true);
    } else {
      _onChange(false);
    }
  }

  void _onChange(bool isOpen) {
    for (final listener in _changeListeners.values) {
      listener(isOpen);
    }
  }
}
