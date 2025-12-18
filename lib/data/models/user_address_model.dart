/// User Address Model
/// Maps address data from API/Firestore
class UserAddressModel {
  final String? street;
  final String? city;
  final String? state;
  final String? country;
  final String? zipCode;

  UserAddressModel({
    this.street,
    this.city,
    this.state,
    this.country,
    this.zipCode,
  });

  factory UserAddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserAddressModel();

    return UserAddressModel(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
      zipCode: json['zipCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
      if (zipCode != null) 'zipCode': zipCode,
    };
  }
}
