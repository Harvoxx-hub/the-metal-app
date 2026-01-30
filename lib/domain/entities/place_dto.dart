/// Result of a place search (from map/places API).
/// Used for location search in Create LinkUp and elsewhere.
class PlaceSearchResultDto {
  final String displayName;
  final double latitude;
  final double longitude;
  final String? placeId;
  final String? type;

  const PlaceSearchResultDto({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    this.placeId,
    this.type,
  });
}
