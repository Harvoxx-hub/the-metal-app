import 'package:metal/core/config/map_config.dart';
import 'package:metal/core/error_handling/error_handler.dart';
import 'package:metal/core/state/base.state.dart';
import 'package:metal/data/datasources/remote/google_places_data_source.dart';
import 'package:metal/data/datasources/remote/place_remote_data_source.dart';
import 'package:metal/data/repositories/place/place_repository_abstract.dart';
import 'package:metal/domain/entities/place_dto.dart';

/// Place repository implementation. Uses Google Places when [MapConfig] has
/// an API key, otherwise Nominatim (OpenStreetMap).
class PlaceRepository implements PlaceRepositoryAbstract {
  final PlaceRemoteDataSource _nominatim;
  final GooglePlacesDataSource? _google;

  PlaceRepository({
    required PlaceRemoteDataSource nominatim,
    GooglePlacesDataSource? google,
  })  : _nominatim = nominatim,
        _google = google;

  bool get _useGoogle => MapConfig.hasGoogleMapsKey && _google != null;

  @override
  Future<BaseState<List<PlaceSearchResultDto>>> searchPlaces(String query) async {
    try {
      if (_useGoogle) {
        try {
          final list = await _google!.searchPlaces(query);
          return BaseState.success(list);
        } catch (e) {
          // Fallback to Nominatim when Google Places fails (e.g. REQUEST_DENIED, API not enabled)
          final list = await _nominatim.searchPlaces(query);
          return BaseState.success(list);
        }
      }
      final list = await _nominatim.searchPlaces(query);
      return BaseState.success(list);
    } catch (e) {
      return ErrorHandler.handleError<List<PlaceSearchResultDto>>(e);
    }
  }

  @override
  Future<BaseState<PlaceSearchResultDto?>> getPlaceDetails(String placeId) async {
    try {
      if (placeId.isEmpty) return BaseState.success(null);
      if (_useGoogle) {
        final place = await _google!.getPlaceDetails(placeId);
        return BaseState.success(place);
      }
      return BaseState.success(null);
    } catch (e) {
      return ErrorHandler.handleError<PlaceSearchResultDto?>(e);
    }
  }

  @override
  Future<PlaceSearchResultDto?> geocodeAddress(String address) async {
    try {
      if (address.trim().isEmpty) return null;
      if (_useGoogle) return await _google!.geocodeAddress(address);
      return null;
    } catch (_) {
      return null;
    }
  }
}
