import 'package:flutter/material.dart';

/// Profile Setup Constants
/// Centralized constants for profile setup screens
class ProfileSetupConstants {
  // Spacing
  static const double horizontalPadding = 20.0;
  static const double verticalPadding = 20.0;
  static const double gapSmall = 16.0;
  static const double gapMedium = 22.0;
  static const double gapLarge = 40.0;
  static const double gapExtraLarge = 64.0;
  static const double headerTopPadding = 45.0;
  static const double buttonBottomPadding = 60.0;

  // Grid Layout
  static const double gridSpacing = 10.0;
  static const int gridCrossAxisCount = 2;
  static const double gridChildAspectRatio = 16 / 6;
  static const double gridChildAspectRatioMetal = 16 / 14;
  static const double gridChildAspectRatioConnection = 12 / 10;
  static const double gridHeightRatio = 0.59;

  // Icon Sizes
  static const double iconSize = 24.0;
  static const double iconSizeSmall = 17.0;

  // Colors
  static const Color errorBackgroundColor = Colors.red;
  static const Color warningBackgroundColor = Colors.orange;
  static const double errorOpacity = 0.1;
  static const double errorBorderOpacity = 0.3;
  static const double disabledOpacity = 0.5;

  // Age Ranges
  static const List<String> ageRanges = [
    "18 - 25 years",
    "25 - 30 years",
    "30 - 35 years",
    "35 - 40 years",
    "40 - 45 years",
    "45 - 50 years",
    "50 - 55 years",
    "55 - 60 years",
    "Above 60 years",
  ];

  // Gender Options
  static const List<String> genderOptions = [
    "Male",
    "Female",
    "Prefer not to say",
    "Others",
  ];

  // Connection Options
  static const List<String> connectionOptions = [
    "Male",
    "Female",
    "Everyone",
  ];

  // Selection Limits
  static const int maxConnectionOptions = 2;
  static const int minPassions = 1;
  static const int minAge = 18;
}

