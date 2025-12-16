import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:metal/core/services/firebase.service.db.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

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

  static String getOtherUserId(List<String> userIds) {
    final myUserId = FirebaseServiceDb.instance.userId;
    if (userIds.length != 2) {
      throw ArgumentError("The list must contain exactly two user IDs.");
    }

    // Use the condition to pick the other ID directly
    return userIds[0] == myUserId ? userIds[1] : userIds[0];
  }

  static String getAgeRange(String dateString) {
    DateFormat dateFormat = DateFormat("dd/MM/yyyy");
    DateTime birthDate = dateFormat.parse(dateString);
    DateTime currentDate = DateTime.now();
    int age = currentDate.year - birthDate.year;

    // Check if the birthday has occurred this year
    if (currentDate.month < birthDate.month ||
        (currentDate.month == birthDate.month &&
            currentDate.day < birthDate.day)) {
      age--;
    }
    return "$age years";
  }
}
