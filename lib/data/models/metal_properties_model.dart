/// Metal properties models for profile setup
/// Contains Metal, Passion, and LookingFor models

class Metal {
  final String title;
  final String desc;
  final String img;
  final String? id;

  Metal({
    required this.title,
    required this.desc,
    required this.img,
    this.id,
  });

  factory Metal.fromJson(Map<String, dynamic> json) {
    return Metal(
      title: json['title'] as String? ?? '',
      desc: json['desc'] as String? ?? '',
      img: json['img'] as String? ?? '',
      id: json['id'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'desc': desc,
        'img': img,
        if (id != null) 'id': id,
      };
}

class Passion {
  final String? title;
  final String? img;

  Passion({this.title, this.img});

  factory Passion.fromJson(Map<String, dynamic> json) {
    return Passion(
      title: json['title'] as String?,
      img: json['img'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (img != null) 'img': img,
      };
}

class LookingFor {
  final String? title;
  final String? desc;

  LookingFor({this.title, this.desc});

  factory LookingFor.fromJson(Map<String, dynamic> json) {
    return LookingFor(
      title: json['title'] as String?,
      desc: json['desc'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (title != null) 'title': title,
        if (desc != null) 'desc': desc,
      };
}

class MetalPropertiesModel {
  final List<Metal>? metals;
  final List<Passion>? passions;
  final List<String>? profession;
  final List<String>? education;
  final List<String>? country;
  final List<String>? ethnicity;
  final List<String>? religion;
  final List<String>? language;
  final List<String>? marriageStatus;
  final List<LookingFor>? lookingFor;
  final List<String>? demography;

  MetalPropertiesModel({
    this.metals,
    this.passions,
    this.profession,
    this.education,
    this.country,
    this.ethnicity,
    this.religion,
    this.language,
    this.marriageStatus,
    this.lookingFor,
    this.demography,
  });

  factory MetalPropertiesModel.fromJson(Map<String, dynamic> json) {
    return MetalPropertiesModel(
      metals: (json['metals'] as List<dynamic>?)
          ?.map((e) => Metal.fromJson(e as Map<String, dynamic>))
          .toList(),
      passions: (json['passions'] as List<dynamic>?)
          ?.map((e) => Passion.fromJson(e as Map<String, dynamic>))
          .toList(),
      profession: (json['profession'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      education: (json['education'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      country:
          (json['country'] as List<dynamic>?)?.map((e) => e as String).toList(),
      ethnicity: (json['ethnicity'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      religion: (json['religion'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      language: (json['language'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      marriageStatus: (json['marriageStatus'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      lookingFor: (json['lookingFor'] as List<dynamic>?)
          ?.map((e) => LookingFor.fromJson(e as Map<String, dynamic>))
          .toList(),
      demography: (json['demography'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (metals != null) 'metals': metals!.map((e) => e.toJson()).toList(),
        if (passions != null)
          'passions': passions!.map((e) => e.toJson()).toList(),
        if (profession != null) 'profession': profession,
        if (education != null) 'education': education,
        if (country != null) 'country': country,
        if (ethnicity != null) 'ethnicity': ethnicity,
        if (religion != null) 'religion': religion,
        if (language != null) 'language': language,
        if (marriageStatus != null) 'marriageStatus': marriageStatus,
        if (lookingFor != null)
          'lookingFor': lookingFor!.map((e) => e.toJson()).toList(),
        if (demography != null) 'demography': demography,
      };
}
