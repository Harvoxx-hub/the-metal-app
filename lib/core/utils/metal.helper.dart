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

    if (age >= 18 && age <= 23) {
      return "18 - 23";
    } else if (age >= 24 && age <= 29) {
      return "24 - 29";
    } else if (age >= 30 && age <= 35) {
      return "30 - 35";
    } else if (age >= 36 && age <= 41) {
      return "36 - 41";
    } else if (age >= 42 && age <= 47) {
      return "42 - 47";
    } else if (age >= 48 && age <= 53) {
      return "48 - 53";
    } else if (age >= 54 && age <= 59) {
      return "54 - 59";
    } else if (age >= 60 && age <= 65) {
      return "60 - 65";
    } else if (age >= 66 && age <= 71) {
      return "66 - 71";
    } else if (age >= 72 && age <= 77) {
      return "72 - 77";
    } else if (age >= 78 && age <= 83) {
      return "78 - 83";
    } else if (age >= 85 && age <= 90) {
      return "85 - 90";
    } else if (age >= 91 && age <= 100) {
      return "91 - 100";
    } else {
      return "Age is not within any specified range";
    }
  }
 

}
