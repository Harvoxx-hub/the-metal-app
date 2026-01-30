import 'package:metal/core/state/base.state.dart';
import 'package:metal/domain/entities/place_dto.dart';

/// Abstract place repository for location/place search.
abstract class PlaceRepositoryAbstract {
  /// Search places by query (e.g. address, city, venue name).
  Future<BaseState<List<PlaceSearchResultDto>>> searchPlaces(String query);

  /// Get place details (lat/lng, address) by place_id. Used when a provider
  /// (e.g. Google) returns predictions without coordinates until selected.
  Future<BaseState<PlaceSearchResultDto?>> getPlaceDetails(String placeId);
}
