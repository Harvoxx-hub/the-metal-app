import 'dart:convert';

import 'package:metal/features/home_page/domain/entries/thought.model.dart';
import 'package:metal/features/notification/domain/entries/notification.model.dart';

class MetalHelper {
  static Map<String, dynamic>? parseJson(String jsonString) {
    try {
      if (jsonString.isEmpty) {
        return null;
      }
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      print('Error parsing JSON: $e');
      return null;
    }
  }

  static List<ThoughtModel> sortThoughtsByDate(List<ThoughtModel> thoughts) {
    thoughts.sort((a, b) {
      DateTime? dateA =
          a.createdAt != null ? DateTime.parse(a.createdAt!) : null;
      DateTime? dateB =
          b.createdAt != null ? DateTime.parse(b.createdAt!) : null;

      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;

      return dateB.compareTo(dateA);
    });

    return thoughts;
  }

 
}
