import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PlayerManager extends ChangeNotifier {
 
  String? _currentPath;

  String get currentPath => _currentPath ?? '';

 

  void togglePlayPause(String path) async {
    _currentPath = path;

    notifyListeners();
  }
}

final playerManagerProvider = ChangeNotifierProvider((ref) => PlayerManager());
