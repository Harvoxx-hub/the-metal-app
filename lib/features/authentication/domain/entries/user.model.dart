class UserModel {
  bool? profileUpdated;
  bool? completedProfile;
  String? dob;
  Address? address;
  String? connectWith;
  List<String>? connectionOption;
  String? description;
  ExtraData? extraData;
  String? fullname;
  String? gender;
  bool? isVerified;
  bool? isActivated;
  Location? location;
  String? metal;
  List<String>? passion;
  String? phone;
  String? email;
  bool? emailVerified;
  String? workEmail;
  bool? workEmailVerified;
  Preferences? preferences;
  String? username;
  String? refreshToken;
  dynamic subscription;
  double sparkBalance;
  String? distance;
  String? id;
  String? referralCode;
  String? referredBy;
  bool showOnline;
  bool alwaysMetal;
  bool receiveNotification;
  bool showMyProfile;
  bool activateVoiceNote;
  bool activateVoiceCall;
  bool activateVideoCall;
  String? profilePhoto;
  String? fcmToken;
  bool isOnline;
  String? lastActive;
  String? createdAt;
  String? updatedAt;
 

  UserModel({
    this.profileUpdated,
    this.completedProfile,
    this.dob,
    this.address,
    this.connectWith,
    this.connectionOption,
    this.description,
    this.extraData,
    this.fullname,
    this.gender,
    this.isVerified,
    this.isActivated,
    this.location,
    this.metal,
    this.passion,
    this.phone,
    this.email,
    this.emailVerified,
    this.workEmail,
    this.workEmailVerified,
    this.preferences,
    this.username,
    this.refreshToken,
    this.subscription,
    this.sparkBalance = 0,
    this.distance,
    this.id,
    this.referralCode,
    this.referredBy,
    this.showOnline = true,
    this.alwaysMetal = true,
    this.receiveNotification = true,
    this.showMyProfile = true,
    this.activateVoiceNote = true,
    this.activateVoiceCall = true,
    this.activateVideoCall = true,
    this.profilePhoto,
    this.fcmToken,
    this.isOnline = true,
    this.lastActive,
    this.createdAt,
    this.updatedAt,
 
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      profileUpdated: json['profileUpdated'] as bool?,
      completedProfile: json['completedProfile'] as bool?,
      dob: json['dob'] as String?,
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      connectWith: json['connectWith'] as String?,
      connectionOption:
          (json['connectionOption'] as List?)?.map((e) => e as String).toList(),
      description: json['description'] as String?,
      extraData: json['extraData'] != null
          ? ExtraData.fromJson(json['extraData'])
          : null,
      fullname: json['fullname'] as String?,
      gender: json['gender'] as String?,
      isVerified: json['isVerified']  as bool?,
      isActivated: json['isActivated'] as bool?,
      location:
          json['location'] != null ? Location.fromJson(json['location']) : null,
      metal: json['metal'] as String?,
      passion: (json['passion'] as List?)?.map((e) => e as String).toList(),
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      emailVerified: json['emailVerified'] as bool?,
      workEmail: json['workEmail'] as String?,
      workEmailVerified: json['workEmailVerified'] as bool?,
      preferences: json['preferences'] != null
          ? Preferences.fromJson(json['preferences'])
          : null,
      username: json['username'] as String?,
      refreshToken: json['refreshToken'] as String?,
      subscription: json['subscription'],
      sparkBalance: (json['sparkBalance'] as num?)?.toDouble() ?? 0,
      distance: json['distance'] as String?,
      id: json['id'] as String?,
      referralCode: json['referralCode'] as String?,
      referredBy: json['referredBy'] as String?,
      showOnline: json['showOnline'] as bool? ?? true,
      alwaysMetal: json['alwaysMetal'] as bool? ?? true,
      receiveNotification: json['receiveNotification'] as bool? ?? true,
      showMyProfile: json['showMyProfile'] as bool? ?? true,
      activateVoiceNote: json['activateVoiceNote'] as bool? ?? true,
      activateVoiceCall: json['activateVoiceCall'] as bool? ?? true,
      activateVideoCall: json['activateVideoCall'] as bool? ?? true,
      profilePhoto: json['profilePhoto'] as String?,
      fcmToken: json['fcmToken'] as String?,
      isOnline: json['isOnline'] as bool? ?? true,
      lastActive: json['lastActive'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'profileUpdated': profileUpdated,
      'completedProfile': completedProfile,
      'dob': dob,
      'address': address?.toJson(),
      'connectWith': connectWith,
      'connectionOption': connectionOption,
      'description': description,
      'extraData': extraData?.toJson(),
      'fullname': fullname,
      'gender': gender,
      'isVerified': isVerified,
      'isActivated': isActivated,
      'location': location?.toJson(),
      'metal': metal,
      'passion': passion,
      'phone': phone,
      'email': email,
      'emailVerified': emailVerified,
      'workEmail': workEmail,
      'workEmailVerified': workEmailVerified,
      'preferences': preferences?.toJson(),
      'username': username,
      'refreshToken': refreshToken,
      'subscription': subscription,
      'sparkBalance': sparkBalance,
      'distance': distance,
      'id': id,
      'referralCode': referralCode,
      'referredBy': referredBy,
      'showOnline': showOnline,
      'alwaysMetal': alwaysMetal,
      'receiveNotification': receiveNotification,
      'showMyProfile': showMyProfile,
      'activateVoiceNote': activateVoiceNote,
      'activateVoiceCall': activateVoiceCall,
      'activateVideoCall': activateVideoCall,
      'profilePhoto': profilePhoto,
      'fcmToken': fcmToken,
      'isOnline': isOnline,
      'lastActive': lastActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
 
    };
  }

  UserModel copyWith({
    bool? profileUpdated,
    bool? completedProfile,
    String? dob,
    Address? address,
    String? connectWith,
    List<String>? connectionOption,
    String? description,
    ExtraData? extraData,
    String? fullname,
    String? gender,
    bool? isVerified,
    bool? isActivated,
    Location? location,
    String? metal,
    List<String>? passion,
    String? phone,
    String? email,
    bool? emailVerified,
    String? workEmail,
    bool? workEmailVerified,
    Preferences? preferences,
    String? username,
    String? refreshToken,
    dynamic subscription,
    double? sparkBalance,
    String? distance,
    String? id,
    String? referralCode,
    String? referredBy,
    bool? showOnline,
    bool? alwaysMetal,
    bool? receiveNotification,
    bool? showMyProfile,
    bool? activateVoiceNote,
    bool? activateVoiceCall,
    bool? activateVideoCall,
    String? profilePhoto,
    String? fcmToken,
    bool? isOnline,
    String? lastActive,
    String? createdAt,
    String? updatedAt,
    bool? isWorkEmailVerified,
  }) {
    return UserModel(
      profileUpdated: profileUpdated ?? this.profileUpdated,
      completedProfile: completedProfile ?? this.completedProfile,
      dob: dob ?? this.dob,
      address: address ?? this.address,
      connectWith: connectWith ?? this.connectWith,
      connectionOption: connectionOption ?? this.connectionOption,
      description: description ?? this.description,
      extraData: extraData ?? this.extraData,
      fullname: fullname ?? this.fullname,
      gender: gender ?? this.gender,
      isVerified: isVerified ?? this.isVerified,
      isActivated: isActivated ?? this.isActivated,
      location: location ?? this.location,
      metal: metal ?? this.metal,
      passion: passion ?? this.passion,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      workEmail: workEmail ?? this.workEmail,
      workEmailVerified: workEmailVerified ?? this.workEmailVerified,
      preferences: preferences ?? this.preferences,
      username: username ?? this.username,
      refreshToken: refreshToken ?? this.refreshToken,
      subscription: subscription ?? this.subscription,
      sparkBalance: sparkBalance ?? this.sparkBalance,
      distance: distance ?? this.distance,
      id: id ?? this.id,
      referralCode: referralCode ?? this.referralCode,
      referredBy: referredBy ?? this.referredBy,
      showOnline: showOnline ?? this.showOnline,
      alwaysMetal: alwaysMetal ?? this.alwaysMetal,
      receiveNotification: receiveNotification ?? this.receiveNotification,
      showMyProfile: showMyProfile ?? this.showMyProfile,
      activateVoiceNote: activateVoiceNote ?? this.activateVoiceNote,
      activateVoiceCall: activateVoiceCall ?? this.activateVoiceCall,
      activateVideoCall: activateVideoCall ?? this.activateVideoCall,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      fcmToken: fcmToken ?? this.fcmToken,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
 
      );
  }
}

class Address {
  String? apartmentNumber;
  String? houseNumber;
  String? streetName;
  String? postalCode;
  String? state;
  String? country;

  Address({
    this.apartmentNumber,
    this.houseNumber,
    this.streetName,
    this.postalCode,
    this.state,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      apartmentNumber: json['apartmentNumber'] as String?,
      houseNumber: json['houseNumber'] as String?,
      streetName: json['streetName'] as String?,
      postalCode: json['postalCode'] as String?,
      state: json['state'] as String?,
      country: json['country'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'apartmentNumber': apartmentNumber,
      'houseNumber': houseNumber,
      'streetName': streetName,
      'postalCode': postalCode,
      'state': state,
      'country': country,
    };
  }

  /// methos to display the address
  String getDisplayAddress() {
    return '$apartmentNumber $houseNumber $streetName $postalCode $state $country';
  }
}

class ExtraData {
  String? country;
  String? education;
  String? ethnicity;
  String? language;
  String? maritalStatus;
  String? profession;
  String? religion;

  ExtraData({
    this.country,
    this.education,
    this.ethnicity,
    this.language,
    this.maritalStatus,
    this.profession,
    this.religion,
  });

  factory ExtraData.fromJson(Map<String, dynamic> json) {
    return ExtraData(
      country: json['country'] as String?,
      education: json['education'] as String?,
      ethnicity: json['ethnicity'] as String?,
      language: json['language'] as String?,
      maritalStatus: json['maritalStatus'] as String?,
      profession: json['profession'] as String?,
      religion: json['religion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country': country,
      'education': education,
      'ethnicity': ethnicity,
      'language': language,
      'maritalStatus': maritalStatus,
      'profession': profession,
      'religion': religion,
    };
  }
}

class Preferences {
  String? ageRange;
  String? demography;
  String? education;
  String? ethnicity;
  String? religion;

  Preferences({
    this.ageRange,
    this.demography,
    this.education,
    this.ethnicity,
    this.religion,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) {
    return Preferences(
      ageRange: json['ageRange'] as String?,
      demography: json['demography'] as String?,
      education: json['education'] as String?,
      ethnicity: json['ethnicity'] as String?,
      religion: json['religion'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ageRange': ageRange,
      'demography': demography,
      'education': education,
      'ethnicity': ethnicity,
      'religion': religion,
    };
  }
}

class Location {
  double? lat;
  double? lng;
  String? address;

  Location({
    this.lat,
    this.lng,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }
}
