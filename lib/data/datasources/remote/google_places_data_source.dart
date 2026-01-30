import 'package:dio/dio.dart';
import 'package:metal/core/config/map_config.dart';
import 'package:metal/domain/entities/place_dto.dart';

/// Remote data source for place search using Google Places API (Legacy).
/// Requires [MapConfig.googleMapsApiKey] to be set.
class GooglePlacesDataSource {
  GooglePlacesDataSource() : _dio = _createDio();

  final Dio _dio;

  static const String _baseUrl = 'https://maps.googleapis.com/maps/api/place';
  static const int _limit = 8;

  static Dio _createDio() {
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
    ));
  }

  /// Autocomplete: returns predictions with description and place_id.
  /// Lat/lng are 0 until [getPlaceDetails] is called for the selected place_id.
  Future<List<PlaceSearchResultDto>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    final key = MapConfig.googleMapsApiKey;
    if (key.isEmpty) return [];

    try {
      // No 'types' filter so we get addresses + establishments (names that exist on Google Maps)
      final response = await _dio.get<Map<String, dynamic>>(
        '/autocomplete/json',
        queryParameters: {
          'input': query.trim(),
          'key': key,
        },
      );

      final data = response.data;
      if (data == null) return [];

      final status = data['status'] as String?;
      if (status != 'OK') return [];

      final predictions = data['predictions'] as List<dynamic>?;
      if (predictions == null || predictions.isEmpty) return [];

      final list = <PlaceSearchResultDto>[];
      for (final p in predictions.take(_limit)) {
        final map = p as Map<String, dynamic>;
        final description = map['description'] as String? ?? '';
        final placeId = map['place_id'] as String?;
        if (description.isEmpty) continue;
        list.add(PlaceSearchResultDto(
          displayName: description,
          latitude: 0,
          longitude: 0,
          placeId: placeId,
          type: (map['types'] as List<dynamic>?)?.firstOrNull?.toString(),
        ));
      }
      return list;
    } catch (_) {
      rethrow;
    }
  }

  /// Place Details: returns lat/lng and formatted address for a place_id.
  Future<PlaceSearchResultDto?> getPlaceDetails(String placeId) async {
    if (placeId.isEmpty) return null;
    final key = MapConfig.googleMapsApiKey;
    if (key.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': key,
          'fields': 'geometry,formatted_address,name',
        },
      );

      final data = response.data;
      if (data == null) return null;

      final status = data['status'] as String?;
      if (status != 'OK') return null;

      final result = data['result'] as Map<String, dynamic>?;
      if (result == null) return null;

      final geometry = result['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      final lat = location != null && location['lat'] != null
          ? (location['lat'] as num).toDouble()
          : 0.0;
      final lng = location != null && location['lng'] != null
          ? (location['lng'] as num).toDouble()
          : 0.0;
      final formattedAddress =
          result['formatted_address'] as String? ?? result['name'] as String? ?? '';

      return PlaceSearchResultDto(
        displayName: formattedAddress.isNotEmpty
            ? formattedAddress
            : (result['name'] as String? ?? ''),
        latitude: lat,
        longitude: lng,
        placeId: placeId,
        type: null,
      );
    } catch (_) {
      rethrow;
    }
  }
}
