/// User Location Model
/// Maps location data from API/Firestore
class UserLocationModel {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final String? state;
  final String? country;

  UserLocationModel({
    this.latitude,
    this.longitude,
    this.address,
    this.city,
    this.state,
    this.country,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserLocationModel();
    
    // Handle both 'latitude/longitude' (Firestore) and 'lat/lng' (legacy) formats
    final lat = json['latitude'] ?? json['lat'];
    final lng = json['longitude'] ?? json['lng'];
    
    return UserLocationModel(
      latitude: lat != null ? (lat as num).toDouble() : null,
      longitude: lng != null ? (lng as num).toDouble() : null,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
    };
  }
}

