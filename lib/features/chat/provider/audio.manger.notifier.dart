import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
 

class PlayerManager extends ChangeNotifier {
  final Map<String, String?> _localPaths = {};
 
  String? _currentPath;

  String get currentPath => _currentPath ?? '';
  
  Map<String, String?> get localPaths => _localPaths;

  Future<void> preparePlayer(String path) async {
    print("Preparing player for path: $path");
    String? localPath = path;
   
    _localPaths[path] = localPath;

    notifyListeners();
    print("Player prepared successfully for path: $path");
  }

  void togglePlayPause(String path) async {
    _currentPath = path;

    notifyListeners();
  }

 
}

final playerManagerProvider = ChangeNotifierProvider((ref) => PlayerManager());
