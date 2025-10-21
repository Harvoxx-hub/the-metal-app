import 'dart:math';
import 'package:metal/core/utils/metal.helper.dart';
import 'package:metal/features/authentication/domain/entries/user.model.dart';
import 'package:metal/features/thought/data/domain/entries/thought.model.dart';

/// Helper class for filtering feed data based on user preferences and remote config rules
class FeedFilterHelper {
  /// Applies filters to a list of data based on user preferences and remote config rules
  /// Uses embedded AuthorMetadata for performance optimization (denormalization strategy)
  ///
  /// [data] - List of items to filter (e.g., ThoughtModel)
  /// [currentUser] - Current user's preferences and data
  /// [rulesJson] - Parsed map of rules from Firebase Remote Config
  /// [getUserById] - Function to get user data by ID for filtering (fallback for legacy data)
  ///
  /// Returns filtered and optionally sorted list
  static List<T> applyFilters<T>({
    required List<T> data,
    required UserModel currentUser,
    required Map<String, dynamic> rulesJson,
    required Future<UserModel?> Function(String userId) getUserById,
  }) {
    // If no rules or data, return original data
    if (rulesJson.isEmpty || data.isEmpty) {
      return data;
    }

    // Check if filters are globally enabled
    final bool filtersEnabled = rulesJson['filters_enabled'] == true;
    if (!filtersEnabled) {
      return data; // Return unfiltered data if filters are disabled
    }

    List<T> filteredData = List.from(data);

    // Extract filter settings from rules
    final bool enableGenderFilter = rulesJson['enable_gender_filter'] == true;
    final bool enableAgeFilter = rulesJson['enable_age_filter'] == true;
    final bool enableLocationPriority =
        rulesJson['enable_location_priority'] == true;
    final bool enableRelationshipFilter =
        rulesJson['enable_relationship_filter'] == true;

    // Age range settings from current user preference age range
    final Map<String, int> ageRange =
        _parseAgeRange(currentUser.preferences?.ageRange);
    final int minAge = ageRange['minAge'] ?? rulesJson['min_age'] ?? 18;
    final int maxAge = ageRange['maxAge'] ?? rulesJson['max_age'] ?? 100;

    // Location settings (with default if not specified in remote config)
    final double maxDistanceKm =
        (rulesJson['max_distance_km'] ?? 50.0).toDouble();

    // Apply filters synchronously for immediate filtering
    filteredData = filteredData.where((item) {
      return _passesFilters(
        item: item,
        currentUser: currentUser,
        enableGenderFilter: enableGenderFilter,
        enableAgeFilter: enableAgeFilter,
        enableLocationPriority: enableLocationPriority,
        enableRelationshipFilter: enableRelationshipFilter,
        minAge: minAge,
        maxAge: maxAge,
        maxDistanceKm: maxDistanceKm,
      );
    }).toList();

    // // Apply location-based sorting if enabled
    // if (enableLocationPriority && currentUser.location != null) {
    //   filteredData = _sortByLocation(
    //     data: filteredData,
    //     currentUser: currentUser,
    //   );
    // }

    // sort by createdAt
    filteredData.sort((a, b) {
      final thoughtA = a as ThoughtModel;
      final thoughtB = b as ThoughtModel;
      return thoughtB.createdAt.compareTo(thoughtA.createdAt);
    });

    return filteredData;
  }

  /// Applies filters asynchronously when user data needs to be fetched
  static Future<List<T>> applyFiltersAsync<T>({
    required List<T> data,
    required UserModel currentUser,
    required Map<String, dynamic> rulesJson,
    required Future<UserModel?> Function(String userId) getUserById,
  }) async {
    // If no rules or data, return original data
    if (rulesJson.isEmpty || data.isEmpty) {
      return data;
    }

    // Check if filters are globally enabled
    final bool filtersEnabled = rulesJson['filters_enabled'] == true;
    if (!filtersEnabled) {
      return data; // Return unfiltered data if filters are disabled
    }

    List<T> filteredData = [];

    // Extract filter settings from rules
    final bool enableGenderFilter = rulesJson['enable_gender_filter'] == true;
    final bool enableAgeFilter = rulesJson['enable_age_filter'] == true;
    final bool enableLocationPriority =
        rulesJson['enable_location_priority'] == true;
    final bool enableRelationshipFilter =
        rulesJson['enable_relationship_filter'] == true;

    // Age range settings from current user preference age range
    final Map<String, int> ageRange =
        _parseAgeRange(currentUser.preferences?.ageRange);
    final int minAge = ageRange['minAge'] ?? rulesJson['min_age'] ?? 18;
    final int maxAge = ageRange['maxAge'] ?? rulesJson['max_age'] ?? 100;

    // Location settings (with default if not specified in remote config)
    final double maxDistanceKm =
        (rulesJson['max_distance_km'] ?? 50.0).toDouble();

    // Process each item and fetch user data as needed
    for (final item in data) {
      final bool passes = await _passesFiltersAsync(
        item: item,
        currentUser: currentUser,
        getUserById: getUserById,
        enableGenderFilter: enableGenderFilter,
        enableAgeFilter: enableAgeFilter,
        enableLocationPriority: enableLocationPriority,
        enableRelationshipFilter: enableRelationshipFilter,
        minAge: minAge,
        maxAge: maxAge,
        maxDistanceKm: maxDistanceKm,
      );

      if (passes) {
        filteredData.add(item);
      }
    }

    // Apply location-based sorting if enabled
    if (enableLocationPriority && currentUser.location != null) {
      filteredData = _sortByLocation(
        data: filteredData,
        currentUser: currentUser,
      );
    }

    return filteredData;
  }

  /// Synchronous filter check using embedded AuthorMetadata for performance
  static bool _passesFilters<T>({
    required T item,
    required UserModel currentUser,
    required bool enableGenderFilter,
    required bool enableAgeFilter,
    required bool enableLocationPriority,
    required bool enableRelationshipFilter,
    required int minAge,
    required int maxAge,
    required double maxDistanceKm,
  }) {
    // Extract user ID and author metadata from the item
    String? itemUserId = _extractUserId(item);
    AuthorMetadata? authorMetadata = _extractAuthorMetadata(item);

    if (itemUserId == null || itemUserId == currentUser.id) {
      return true; // Skip filtering for own content or invalid items
    }

    // If no embedded metadata, include unconditionally (legacy data)
    if (authorMetadata == null) {
      return true; // Always include items without metadata
    }

    // Apply gender filter using embedded metadata
    if (enableGenderFilter) {
      if (!_passesGenderFilterWithMetadata(currentUser, authorMetadata)) {
        return false;
      }
    }

    // Apply age filter using embedded metadata
    if (enableAgeFilter) {
      if (!_passesAgeFilterWithMetadata(authorMetadata, minAge, maxAge)) {
        return false;
      }
    }

    // Apply location filter using embedded metadata
    if (enableLocationPriority) {
      if (!_passesLocationFilterWithMetadata(
          currentUser, authorMetadata, maxDistanceKm)) {
        return false;
      }
    }

    // Apply relationship filter using embedded metadata
    if (enableRelationshipFilter) {
      if (!_passesRelationshipFilterWithMetadata(currentUser, authorMetadata)) {
        return false;
      }
    }

    return true;
  }

  /// Asynchronous filter check (fetches user data as needed)
  static Future<bool> _passesFiltersAsync<T>({
    required T item,
    required UserModel currentUser,
    required Future<UserModel?> Function(String userId) getUserById,
    required bool enableGenderFilter,
    required bool enableAgeFilter,
    required bool enableLocationPriority,
    required bool enableRelationshipFilter,
    required int minAge,
    required int maxAge,
    required double maxDistanceKm,
  }) async {
    // Extract user ID from the item
    String? itemUserId = _extractUserId(item);
    if (itemUserId == null || itemUserId == currentUser.id) {
      return true; // Skip filtering for own content or invalid items
    }

    // Fetch user data for the item
    UserModel? itemUser = await getUserById(itemUserId);
    if (itemUser == null) {
      return false; // Filter out items with invalid user data
    }

    // Apply gender filter
    if (enableGenderFilter) {
      if (!_passesGenderFilter(currentUser, itemUser)) {
        return false;
      }
    }

    // Apply age filter
    if (enableAgeFilter) {
      if (!_passesAgeFilter(itemUser, minAge, maxAge)) {
        return false;
      }
    }

    // Apply location filter
    if (enableLocationPriority) {
      if (!_passesLocationFilter(currentUser, itemUser, maxDistanceKm)) {
        return false;
      }
    }

    // Apply relationship filter
    if (enableRelationshipFilter) {
      if (!_passesRelationshipFilter(currentUser, itemUser)) {
        return false;
      }
    }

    return true;
  }

  /// Extract user ID from different item types
  static String? _extractUserId<T>(T item) {
    if (item is ThoughtModel) {
      return item.userId;
    }
    // Add other item types as needed
    // if (item is OtherModel) {
    //   return item.userId;
    // }

    // Try to extract userId using reflection-like approach
    try {
      final dynamic dynamicItem = item;
      if (dynamicItem.userId != null) {
        return dynamicItem.userId as String;
      }
    } catch (e) {
      // Ignore reflection errors
    }

    return null;
  }

  /// Extract AuthorMetadata from different item types
  static AuthorMetadata? _extractAuthorMetadata<T>(T item) {
    if (item is ThoughtModel) {
      return item.authorMetadata;
    }
    // Add other item types as needed
    // if (item is OtherModel) {
    //   return item.authorMetadata;
    // }

    // Try to extract authorMetadata using reflection-like approach
    try {
      final dynamic dynamicItem = item;
      if (dynamicItem.authorMetadata != null) {
        return dynamicItem.authorMetadata as AuthorMetadata;
      }
    } catch (e) {
      // Ignore reflection errors
    }

    return null;
  }

  /// Check if item passes gender filter using embedded metadata
  static bool _passesGenderFilterWithMetadata(
      UserModel currentUser, AuthorMetadata authorMetadata) {
    // Get current user's preferred genders from connectWith
    String? connectWithString = currentUser.connectWith;

    if (connectWithString == null || connectWithString.isEmpty) {
      return true; // No preference set, pass all
    }

    // Split connectWith by comma to get list of preferred genders
    List<String> preferredGenders = connectWithString
        .split(',')
        .map((gender) => gender.trim().toLowerCase())
        .where((gender) => gender.isNotEmpty)
        .toList();

    if (preferredGenders.isEmpty) {
      return true; // No valid preferences, pass all
    }

    // Handle "everyone" or "all" preferences
    if (preferredGenders
        .any((gender) => gender == 'everyone' || gender == 'all')) {
      return true;
    }

    // If author gender is missing, include unconditionally
    if (authorMetadata.authorGender == null ||
        authorMetadata.authorGender!.isEmpty) {
      return true; // Include items with incomplete gender data
    }

    // Check if author's gender matches any of the preferred genders
    String authorGender = authorMetadata.authorGender!.toLowerCase();
    return preferredGenders.contains(authorGender);
  }

  /// Check if item passes age filter using embedded metadata
  static bool _passesAgeFilterWithMetadata(
      AuthorMetadata authorMetadata, int minAge, int maxAge) {
    // If age data is missing, include unconditionally
    if (authorMetadata.authorAge == null) {
      return true; // Include items with incomplete age data
    }

    int age = authorMetadata.authorAge!;
    return age >= minAge && age <= maxAge;
  }

  /// Check if item passes location filter using embedded metadata (demographic-based)
  static bool _passesLocationFilterWithMetadata(UserModel currentUser,
      AuthorMetadata authorMetadata, double maxDistanceKm) {
    // Get current user's demographic preference
    String? userDemographyPreference = currentUser.preferences?.demography;

    // If no demographic preference is set, include all
    if (userDemographyPreference == null || userDemographyPreference.isEmpty) {
      return true;
    }

    // If preference is "Anywhere in the world", include all
    if (userDemographyPreference.toLowerCase() == "anywhere in the world") {
      return true;
    }

    // Get author's lat/lng
    final lat = authorMetadata.authorLatitude;
    final lng = authorMetadata.authorLongitude;
    if (lat == null || lng == null) {
      return true; // Include items with incomplete location data
    }

    // Get author's continent
    final authorContinent = _getContinentFromLatLng(lat, lng);
    if (authorContinent == null) {
      return true; // If we can't determine continent, include
    }

    // Match continent to user preference
    return _isContinentMatch(authorContinent, userDemographyPreference);
  }

  /// Returns the continent name for a given lat/lng, or null if unknown
  static String? _getContinentFromLatLng(double lat, double lng) {
    // Simple bounding box approach for major continents
    if (lat >= -35 && lat <= 37 && lng >= -20 && lng <= 52) return 'Africa';
    if (lat >= 1 && lat <= 77 && lng >= 26 && lng <= 180) return 'Asia';
    if (lat >= 7 && lat <= 83 && lng >= -168 && lng <= -52)
      return 'North America';
    if (lat >= -56 && lat <= 13 && lng >= -81 && lng <= -34)
      return 'South America';
    if (lat >= 34 && lat <= 72 && lng >= -25 && lng <= 60) return 'Europe';
    if (lat >= -50 && lat <= -10 && lng >= 110 && lng <= 180)
      return 'Australia';
    if (lat <= -60) return 'Antarctica';
    return null;
  }

  /// Returns true if the user's demographic preference matches the author's continent
  static bool _isContinentMatch(
      String authorContinent, String userDemographyPreference) {
    if (userDemographyPreference.toLowerCase() == 'anywhere in the world')
      return true;
    return authorContinent.toLowerCase() ==
        userDemographyPreference.toLowerCase();
  }

  /// Check if item passes relationship filter using embedded metadata
  static bool _passesRelationshipFilterWithMetadata(
      UserModel currentUser, AuthorMetadata authorMetadata) {
    // Get current user's preferred relationship types
    List<String>? preferredTypes = currentUser.connectionOption;

    if (preferredTypes == null || preferredTypes.isEmpty) {
      return true; // No preference set, pass all
    }

    // Get author's relationship type
    String? authorRelationshipType = authorMetadata.authorRelationshipType;

    // If relationship data is missing, include unconditionally
    if (authorRelationshipType == null || authorRelationshipType.isEmpty) {
      return true; // Include items with incomplete relationship data
    }

    // Check if author's relationship type matches any preferred type
    return preferredTypes.any((preferred) =>
        preferred.toLowerCase() == authorRelationshipType.toLowerCase());
  }

  /// Check if item passes gender filter
  static bool _passesGenderFilter(UserModel currentUser, UserModel itemUser) {
    // Get current user's preferred genders from connectWith
    String? connectWithString = currentUser.connectWith;

    if (connectWithString == null || connectWithString.isEmpty) {
      return true; // No preference set, pass all
    }

    // Split connectWith by comma to get list of preferred genders
    List<String> preferredGenders = connectWithString
        .split(',')
        .map((gender) => gender.trim().toLowerCase())
        .where((gender) => gender.isNotEmpty)
        .toList();

    if (preferredGenders.isEmpty) {
      return true; // No valid preferences, pass all
    }

    // Handle "everyone" or "all" preferences
    if (preferredGenders
        .any((gender) => gender == 'everyone' || gender == 'all')) {
      return true;
    }

    // If item user's gender is missing, include unconditionally
    if (itemUser.gender == null || itemUser.gender!.isEmpty) {
      return true; // Include items with incomplete gender data
    }

    // Check if item user's gender matches any of the preferred genders
    String itemGender = itemUser.gender!.toLowerCase();
    return preferredGenders.contains(itemGender);
  }

  /// Check if item passes age filter
  static bool _passesAgeFilter(UserModel itemUser, int minAge, int maxAge) {
    if (itemUser.dob == null || itemUser.dob!.isEmpty) {
      return true; // No age data, pass through
    }

    try {
      DateTime birthDate = DateTime.parse(itemUser.dob!);
      int age = DateTime.now().difference(birthDate).inDays ~/ 365;
      return age >= minAge && age <= maxAge;
    } catch (e) {
      return true; // Invalid date format, pass through
    }
  }

  /// Check if item passes location filter
  static bool _passesLocationFilter(
      UserModel currentUser, UserModel itemUser, double maxDistanceKm) {
    if (currentUser.location == null ||
        itemUser.location == null ||
        currentUser.location!.lat == null ||
        currentUser.location!.lng == null ||
        itemUser.location!.lat == null ||
        itemUser.location!.lng == null) {
      return true; // No location data, pass through
    }

    double distance = _calculateDistance(
      currentUser.location!.lat!,
      currentUser.location!.lng!,
      itemUser.location!.lat!,
      itemUser.location!.lng!,
    );

    return distance <= maxDistanceKm;
  }

  /// Check if item passes relationship filter
  static bool _passesRelationshipFilter(
      UserModel currentUser, UserModel itemUser) {
    // Get current user's preferred relationship types
    List<String>? preferredTypes = currentUser.connectionOption;

    if (preferredTypes == null || preferredTypes.isEmpty) {
      return true; // No preference set, pass all
    }

    // Get item user's relationship type
    String? userRelationshipType = itemUser.extraData?.maritalStatus;

    if (userRelationshipType == null || userRelationshipType.isEmpty) {
      return true; // No relationship data, pass through
    }

    // Check if user's relationship type matches any preferred type
    return preferredTypes.any((preferred) =>
        preferred.toLowerCase() == userRelationshipType.toLowerCase());
  }

  /// Sort data by location proximity
  static List<T> _sortByLocation<T>({
    required List<T> data,
    required UserModel currentUser,
  }) {
    if (currentUser.location?.lat == null ||
        currentUser.location?.lng == null) {
      return data; // No current user location, return unsorted
    }

    List<T> sortedData = List.from(data);

    sortedData.sort((a, b) {
      double distanceA = _getItemDistance(a, currentUser);
      double distanceB = _getItemDistance(b, currentUser);
      return distanceA.compareTo(distanceB);
    });

    return sortedData;
  }

  /// Get distance for an item using embedded AuthorMetadata
  static double _getItemDistance<T>(T item, UserModel currentUser) {
    if (currentUser.location?.lat == null ||
        currentUser.location?.lng == null) {
      return double.infinity; // No current user location
    }

    AuthorMetadata? authorMetadata = _extractAuthorMetadata(item);
    if (authorMetadata?.authorLatitude == null ||
        authorMetadata?.authorLongitude == null) {
      return double.infinity; // No item location data
    }

    return _calculateDistance(
      currentUser.location!.lat!,
      currentUser.location!.lng!,
      authorMetadata!.authorLatitude!,
      authorMetadata.authorLongitude!,
    );
  }

  /// Calculate distance between two coordinates using Haversine formula
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;
  }

  /// Convert degrees to radians
  static double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  /// Parse rules from Firebase Remote Config JSON string
  static Map<String, dynamic> parseRules(String rulesJson) {
    if (rulesJson.isEmpty) {
      return {};
    }

    return MetalHelper.parseJson(rulesJson) ?? {};
  }

  /// Get default filter rules that match the Remote Config structure
  static Map<String, dynamic> getDefaultRules() {
    return {
      'filters_enabled': false,
      'enable_gender_filter': false,
      'enable_age_filter': false,
      'enable_location_priority': false,
      'enable_relationship_filter': false,
      'min_age': 18,
      'max_age': 100,
      'max_distance_km': 50.0,
    };
  }

  /// Parse age range string like "18 - 25 years" into min and max age integers
  static Map<String, int> _parseAgeRange(String? ageRangeString) {
    if (ageRangeString == null || ageRangeString.isEmpty) {
      return {'minAge': 18, 'maxAge': 100}; // Default range
    }

    try {
      // Remove common suffixes like "years", "year", "yrs", etc.
      String cleanedString = ageRangeString
          .toLowerCase()
          .replaceAll(RegExp(r'\b(years?|yrs?)\b'), '') // Remove year suffixes
          .replaceAll(RegExp(r'\s+'), ' ') // Normalize whitespace
          .trim();

      // Split by common separators
      List<String> parts = [];
      if (cleanedString.contains(' - ')) {
        parts = cleanedString.split(' - ');
      } else if (cleanedString.contains('-')) {
        parts = cleanedString.split('-');
      } else if (cleanedString.contains(' to ')) {
        parts = cleanedString.split(' to ');
      } else if (cleanedString.contains('to')) {
        parts = cleanedString.split('to');
      } else {
        // Try to extract numbers using regex
        RegExp numberRegex = RegExp(r'\d+');
        Iterable<Match> matches = numberRegex.allMatches(cleanedString);
        parts = matches.map((match) => match.group(0)!).toList();
      }

      if (parts.length >= 2) {
        int minAge = int.parse(parts[0].trim());
        int maxAge = int.parse(parts[1].trim());

        // Ensure valid range
        if (minAge > maxAge) {
          int temp = minAge;
          minAge = maxAge;
          maxAge = temp;
        }

        return {'minAge': minAge, 'maxAge': maxAge};
      }
    } catch (e) {
      // If parsing fails, return default range
    }

    return {'minAge': 18, 'maxAge': 100}; // Default range if parsing fails
  }
}
