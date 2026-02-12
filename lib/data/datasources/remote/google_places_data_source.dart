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

  /// Autocomplete: returns predictions (addresses + businesses/companies/landmarks).
  /// Uses both unrestricted and establishment types so company names and places show.
  /// Lat/lng are 0 until [getPlaceDetails] is called for the selected place_id.
  Future<List<PlaceSearchResultDto>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    final key = MapConfig.googleMapsApiKey;
    if (key.isEmpty) return [];

    try {
      // Request 1: no type filter (addresses, regions, etc.)
      final responseAll = await _dio.get<Map<String, dynamic>>(
        '/autocomplete/json',
        queryParameters: {
          'input': query.trim(),
          'key': key,
          'language': 'en',
        },
      );
      // Request 2: establishment only (businesses, companies, landmarks)
      final responseEstablishment = await _dio.get<Map<String, dynamic>>(
        '/autocomplete/json',
        queryParameters: {
          'input': query.trim(),
          'key': key,
          'types': 'establishment',
          'language': 'en',
        },
      );

      final dataAll = responseAll.data;
      if (dataAll != null) {
        final status = dataAll['status'] as String?;
        if (status != 'OK' && status != 'ZERO_RESULTS') {
          final errorMsg = dataAll['error_message'] as String? ??
              (status == 'REQUEST_DENIED'
                  ? 'Places API is not enabled. Enable "Places API" in Google Cloud Console for your key.'
                  : 'Places search failed ($status).');
          throw Exception(errorMsg);
        }
      }

      final seenIds = <String>{};
      final list = <PlaceSearchResultDto>[];

      void addFromResponse(Map<String, dynamic>? data) {
        if (data == null) return;
        final status = data['status'] as String?;
        if (status != 'OK' && status != 'ZERO_RESULTS') return;
        final predictions = data['predictions'] as List<dynamic>?;
        if (predictions == null) return;
        for (final p in predictions) {
          if (list.length >= _limit) return;
          final map = p as Map<String, dynamic>;
          final placeId = map['place_id'] as String?;
          if (placeId == null || placeId.isEmpty || seenIds.contains(placeId)) continue;
          seenIds.add(placeId);
          final description = map['description'] as String? ?? '';
          final structured = map['structured_formatting'] as Map<String, dynamic>?;
          final mainText = structured?['main_text'] as String?;
          final secondaryText = structured?['secondary_text'] as String?;
          final displayName = description.isNotEmpty
              ? description
              : [
                  if (mainText != null && mainText.isNotEmpty) mainText,
                  if (secondaryText != null && secondaryText.isNotEmpty) secondaryText,
                ].join(', ');
          if (displayName.isEmpty) continue;
          list.add(PlaceSearchResultDto(
            displayName: displayName,
            latitude: 0,
            longitude: 0,
            placeId: placeId,
            type: (map['types'] as List<dynamic>?)?.firstOrNull?.toString(),
          ));
        }
      }

      addFromResponse(responseAll.data);
      addFromResponse(responseEstablishment.data);

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
      if (status != 'OK') {
        final errorMsg = data['error_message'] as String? ??
            (status == 'REQUEST_DENIED'
                ? 'Places API is not enabled. Enable "Places API" in Google Cloud Console for your key.'
                : 'Place details failed ($status).');
        throw Exception(errorMsg);
      }

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

  /// Geocode an address/place name to lat/lng using Google Geocoding API.
  /// Use when meetup has placeName but no placeLocation (e.g. old data).
  Future<PlaceSearchResultDto?> geocodeAddress(String address) async {
    if (address.trim().isEmpty) return null;
    final key = MapConfig.googleMapsApiKey;
    if (key.isEmpty) return null;

    try {
      final response = await _dio.get<Map<String, dynamic>>(
        'https://maps.googleapis.com/maps/api/geocode/json',
        queryParameters: {
          'address': address.trim(),
          'key': key,
        },
      );

      final data = response.data;
      if (data == null) return null;

      final status = data['status'] as String?;
      if (status != 'OK' && status != 'ZERO_RESULTS') return null;
      final results = data['results'] as List<dynamic>?;
      if (results == null || results.isEmpty) return null;

      final first = results.first as Map<String, dynamic>;
      final geometry = first['geometry'] as Map<String, dynamic>?;
      final location = geometry?['location'] as Map<String, dynamic>?;
      if (location == null) return null;

      final lat = (location['lat'] as num?)?.toDouble();
      final lng = (location['lng'] as num?)?.toDouble();
      if (lat == null || lng == null || !lat.isFinite || !lng.isFinite) return null;

      final formatted = first['formatted_address'] as String? ?? address.trim();
      return PlaceSearchResultDto(
        displayName: formatted,
        latitude: lat,
        longitude: lng,
        placeId: null,
        type: null,
      );
    } catch (_) {
      return null;
    }
  }
}
