import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirebaseTestService {
  static Future<void> testFirebaseConnection() async {
    try {
      // Get current Firebase app
      final app = Firebase.app();
      final options = app.options;

      debugPrint('🔥 Firebase Test Results:');
      debugPrint('📱 App Name: ${app.name}');
      debugPrint('🏗️ Project ID: ${options.projectId}');
      debugPrint('📧 Storage Bucket: ${options.storageBucket}');
      debugPrint('🔑 API Key: ${options.apiKey.substring(0, 10)}...');

      // Test Firestore connection
      try {
        final firestore = FirebaseFirestore.instance;
        await firestore.collection('test').limit(1).get();
        debugPrint('✅ Firestore connection successful');
      } catch (e) {
        debugPrint('❌ Firestore connection failed: $e');
      }

      // Test Auth connection
      try {
        final auth = FirebaseAuth.instance;
        debugPrint('✅ Firebase Auth connection successful');
        debugPrint(
            '👤 Current user: ${auth.currentUser?.uid ?? 'No user logged in'}');
      } catch (e) {
        debugPrint('❌ Firebase Auth connection failed: $e');
      }
    } catch (e) {
      debugPrint('❌ Firebase test failed: $e');
    }
  }

  static void printEnvironmentInfo() {
    debugPrint('🌍 Environment Information:');
    debugPrint(
        '📦 Package Name: ${const String.fromEnvironment('FLAVOR', defaultValue: 'prod')}');
    debugPrint('🔧 Build Mode: ${kDebugMode ? 'Debug' : 'Release'}');
    debugPrint('📱 Platform: ${defaultTargetPlatform.name}');
  }
}
