/// User Extra Data Model
/// Maps extra user data from API/Firestore
class UserExtraDataModel {
  final String? profession;
  final String? education;
  final String? religion;
  final String? ethnicity;
  final String? language;
  final String? marriageStatus;

  UserExtraDataModel({
    this.profession,
    this.education,
    this.religion,
    this.ethnicity,
    this.language,
    this.marriageStatus,
  });

  factory UserExtraDataModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserExtraDataModel();
    
    final marriage = json['marriageStatus'] as String? ??
        json['maritalStatus'] as String?;

    return UserExtraDataModel(
      profession: json['profession'] as String?,
      education: json['education'] as String?,
      religion: json['religion'] as String?,
      ethnicity: json['ethnicity'] as String?,
      language: json['language'] as String?,
      marriageStatus: marriage,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (profession != null) 'profession': profession,
      if (education != null) 'education': education,
      if (religion != null) 'religion': religion,
      if (ethnicity != null) 'ethnicity': ethnicity,
      if (language != null) 'language': language,
      if (marriageStatus != null) 'marriageStatus': marriageStatus,
    };
  }
}

