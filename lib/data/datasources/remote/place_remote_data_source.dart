import 'package:dio/dio.dart';
import 'package:metal/domain/entities/place_dto.dart';

/// Remote data source for place/location search.
/// Uses OpenStreetMap Nominatim API (no API key required).
/// Keeps a separate Dio instance for external API to avoid mixing with app API.
class PlaceRemoteDataSource {
  PlaceRemoteDataSource() : _dio = _createDio();

  final Dio _dio;

  static const String _baseUrl = 'https://nominatim.openstreetmap.org';
  static const int _limit = 8;

  static Dio _createDio() {
    return Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'MetalApp/1.0 (contact@metal.app)',
      },
    ));
  }

  /// Search for places by query string.
  /// Returns a list of [PlaceSearchResultDto] or empty list on error.
  Future<List<PlaceSearchResultDto>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final response = await _dio.get<List<dynamic>>(
        '/search',
        queryParameters: {
          'q': query.trim(),
          'format': 'json',
          'addressdetails': 1,
          'limit': _limit,
        },
      );

      if (response.data == null || response.data is! List) {
        return [];
      }

      final list = response.data as List<dynamic>;
      return list.map((e) {
        final map = e as Map<String, dynamic>;
        final lat = (map['lat'] is num) ? (map['lat'] as num).toDouble() : 0.0;
        final lon = (map['lon'] is num) ? (map['lon'] as num).toDouble() : 0.0;
        return PlaceSearchResultDto(
          displayName: map['display_name'] as String? ?? '',
          latitude: lat,
          longitude: lon,
          placeId: map['place_id']?.toString(),
          type: map['type'] as String?,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }
}
