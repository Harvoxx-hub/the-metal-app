/// User Preferences Model
/// Maps user preferences from API/Firestore
class UserPreferencesModel {
  final String? ageRange;
  final String? demography;
  final String? education;
  final String? ethnicity;
  final String? religion;

  UserPreferencesModel({
    this.ageRange,
    this.demography,
    this.education,
    this.ethnicity,
    this.religion,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserPreferencesModel();

    return UserPreferencesModel(
      ageRange: json['ageRange'] as String?,
      demography: json['demography'] as String?,
      education: json['education'] as String?,
      ethnicity: json['ethnicity'] as String?,
      religion: json['religion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (ageRange != null) 'ageRange': ageRange,
      if (demography != null) 'demography': demography,
      if (education != null) 'education': education,
      if (ethnicity != null) 'ethnicity': ethnicity,
      if (religion != null) 'religion': religion,
    };
  }
}
