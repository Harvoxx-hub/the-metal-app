// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  bool? get profileUpdated => throw _privateConstructorUsedError;
  bool? get completedProfile => throw _privateConstructorUsedError;
  String? get dob => throw _privateConstructorUsedError;
  Address? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'connectWith')
  String? get connectWith => throw _privateConstructorUsedError;
  @JsonKey(name: 'connectionOption')
  List<String>? get connectionOption => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'extraData')
  ExtraData? get extraData => throw _privateConstructorUsedError;
  String? get fullname => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  bool? get isVerified => throw _privateConstructorUsedError;
  bool? get isActivated => throw _privateConstructorUsedError;
  Location? get location => throw _privateConstructorUsedError;
  String? get metal => throw _privateConstructorUsedError;
  List<String>? get passion => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  bool? get emailVerified => throw _privateConstructorUsedError;
  Preferences? get preferences => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  String? get refreshToken => throw _privateConstructorUsedError;
  SubscribedPlanModel? get subscription => throw _privateConstructorUsedError;
  double get sparkBalance => throw _privateConstructorUsedError;
  String? get distance => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  String? get referralCode => throw _privateConstructorUsedError;
  String? get referredBy => throw _privateConstructorUsedError;
  bool get showOnline => throw _privateConstructorUsedError;
  bool get alwaysMetal => throw _privateConstructorUsedError;
  bool get receiveNotification => throw _privateConstructorUsedError;
  bool get showMyProfile => throw _privateConstructorUsedError;
  bool get activateVoiceNote => throw _privateConstructorUsedError;
  bool get activateVoiceCall => throw _privateConstructorUsedError;
  bool get activateVideoCall => throw _privateConstructorUsedError;
  String? get profilePhoto => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;
  bool get isOnline => throw _privateConstructorUsedError;
  String? get lastActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'blockedUsers')
  List<String>? get blockedUsers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {bool? profileUpdated,
      bool? completedProfile,
      String? dob,
      Address? address,
      @JsonKey(name: 'connectWith') String? connectWith,
      @JsonKey(name: 'connectionOption') List<String>? connectionOption,
      String? description,
      @JsonKey(name: 'extraData') ExtraData? extraData,
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
      Preferences? preferences,
      String? username,
      String? refreshToken,
      SubscribedPlanModel? subscription,
      double sparkBalance,
      String? distance,
      String? id,
      String? referralCode,
      String? referredBy,
      bool showOnline,
      bool alwaysMetal,
      bool receiveNotification,
      bool showMyProfile,
      bool activateVoiceNote,
      bool activateVoiceCall,
      bool activateVideoCall,
      String? profilePhoto,
      String? fcmToken,
      bool isOnline,
      String? lastActive,
      @JsonKey(name: 'blockedUsers') List<String>? blockedUsers});

  $AddressCopyWith<$Res>? get address;
  $ExtraDataCopyWith<$Res>? get extraData;
  $LocationCopyWith<$Res>? get location;
  $PreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profileUpdated = freezed,
    Object? completedProfile = freezed,
    Object? dob = freezed,
    Object? address = freezed,
    Object? connectWith = freezed,
    Object? connectionOption = freezed,
    Object? description = freezed,
    Object? extraData = freezed,
    Object? fullname = freezed,
    Object? gender = freezed,
    Object? isVerified = freezed,
    Object? isActivated = freezed,
    Object? location = freezed,
    Object? metal = freezed,
    Object? passion = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? emailVerified = freezed,
    Object? preferences = freezed,
    Object? username = freezed,
    Object? refreshToken = freezed,
    Object? subscription = freezed,
    Object? sparkBalance = null,
    Object? distance = freezed,
    Object? id = freezed,
    Object? referralCode = freezed,
    Object? referredBy = freezed,
    Object? showOnline = null,
    Object? alwaysMetal = null,
    Object? receiveNotification = null,
    Object? showMyProfile = null,
    Object? activateVoiceNote = null,
    Object? activateVoiceCall = null,
    Object? activateVideoCall = null,
    Object? profilePhoto = freezed,
    Object? fcmToken = freezed,
    Object? isOnline = null,
    Object? lastActive = freezed,
    Object? blockedUsers = freezed,
  }) {
    return _then(_value.copyWith(
      profileUpdated: freezed == profileUpdated
          ? _value.profileUpdated
          : profileUpdated // ignore: cast_nullable_to_non_nullable
              as bool?,
      completedProfile: freezed == completedProfile
          ? _value.completedProfile
          : completedProfile // ignore: cast_nullable_to_non_nullable
              as bool?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address?,
      connectWith: freezed == connectWith
          ? _value.connectWith
          : connectWith // ignore: cast_nullable_to_non_nullable
              as String?,
      connectionOption: freezed == connectionOption
          ? _value.connectionOption
          : connectionOption // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      extraData: freezed == extraData
          ? _value.extraData
          : extraData // ignore: cast_nullable_to_non_nullable
              as ExtraData?,
      fullname: freezed == fullname
          ? _value.fullname
          : fullname // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      isActivated: freezed == isActivated
          ? _value.isActivated
          : isActivated // ignore: cast_nullable_to_non_nullable
              as bool?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location?,
      metal: freezed == metal
          ? _value.metal
          : metal // ignore: cast_nullable_to_non_nullable
              as String?,
      passion: freezed == passion
          ? _value.passion
          : passion // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      emailVerified: freezed == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Preferences?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      subscription: freezed == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as SubscribedPlanModel?,
      sparkBalance: null == sparkBalance
          ? _value.sparkBalance
          : sparkBalance // ignore: cast_nullable_to_non_nullable
              as double,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      referralCode: freezed == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String?,
      referredBy: freezed == referredBy
          ? _value.referredBy
          : referredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      showOnline: null == showOnline
          ? _value.showOnline
          : showOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      alwaysMetal: null == alwaysMetal
          ? _value.alwaysMetal
          : alwaysMetal // ignore: cast_nullable_to_non_nullable
              as bool,
      receiveNotification: null == receiveNotification
          ? _value.receiveNotification
          : receiveNotification // ignore: cast_nullable_to_non_nullable
              as bool,
      showMyProfile: null == showMyProfile
          ? _value.showMyProfile
          : showMyProfile // ignore: cast_nullable_to_non_nullable
              as bool,
      activateVoiceNote: null == activateVoiceNote
          ? _value.activateVoiceNote
          : activateVoiceNote // ignore: cast_nullable_to_non_nullable
              as bool,
      activateVoiceCall: null == activateVoiceCall
          ? _value.activateVoiceCall
          : activateVoiceCall // ignore: cast_nullable_to_non_nullable
              as bool,
      activateVideoCall: null == activateVideoCall
          ? _value.activateVideoCall
          : activateVideoCall // ignore: cast_nullable_to_non_nullable
              as bool,
      profilePhoto: freezed == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActive: freezed == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as String?,
      blockedUsers: freezed == blockedUsers
          ? _value.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $AddressCopyWith<$Res>? get address {
    if (_value.address == null) {
      return null;
    }

    return $AddressCopyWith<$Res>(_value.address!, (value) {
      return _then(_value.copyWith(address: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $ExtraDataCopyWith<$Res>? get extraData {
    if (_value.extraData == null) {
      return null;
    }

    return $ExtraDataCopyWith<$Res>(_value.extraData!, (value) {
      return _then(_value.copyWith(extraData: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $LocationCopyWith<$Res>? get location {
    if (_value.location == null) {
      return null;
    }

    return $LocationCopyWith<$Res>(_value.location!, (value) {
      return _then(_value.copyWith(location: value) as $Val);
    });
  }

  @override
  @pragma('vm:prefer-inline')
  $PreferencesCopyWith<$Res>? get preferences {
    if (_value.preferences == null) {
      return null;
    }

    return $PreferencesCopyWith<$Res>(_value.preferences!, (value) {
      return _then(_value.copyWith(preferences: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool? profileUpdated,
      bool? completedProfile,
      String? dob,
      Address? address,
      @JsonKey(name: 'connectWith') String? connectWith,
      @JsonKey(name: 'connectionOption') List<String>? connectionOption,
      String? description,
      @JsonKey(name: 'extraData') ExtraData? extraData,
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
      Preferences? preferences,
      String? username,
      String? refreshToken,
      SubscribedPlanModel? subscription,
      double sparkBalance,
      String? distance,
      String? id,
      String? referralCode,
      String? referredBy,
      bool showOnline,
      bool alwaysMetal,
      bool receiveNotification,
      bool showMyProfile,
      bool activateVoiceNote,
      bool activateVoiceCall,
      bool activateVideoCall,
      String? profilePhoto,
      String? fcmToken,
      bool isOnline,
      String? lastActive,
      @JsonKey(name: 'blockedUsers') List<String>? blockedUsers});

  @override
  $AddressCopyWith<$Res>? get address;
  @override
  $ExtraDataCopyWith<$Res>? get extraData;
  @override
  $LocationCopyWith<$Res>? get location;
  @override
  $PreferencesCopyWith<$Res>? get preferences;
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? profileUpdated = freezed,
    Object? completedProfile = freezed,
    Object? dob = freezed,
    Object? address = freezed,
    Object? connectWith = freezed,
    Object? connectionOption = freezed,
    Object? description = freezed,
    Object? extraData = freezed,
    Object? fullname = freezed,
    Object? gender = freezed,
    Object? isVerified = freezed,
    Object? isActivated = freezed,
    Object? location = freezed,
    Object? metal = freezed,
    Object? passion = freezed,
    Object? phone = freezed,
    Object? email = freezed,
    Object? emailVerified = freezed,
    Object? preferences = freezed,
    Object? username = freezed,
    Object? refreshToken = freezed,
    Object? subscription = freezed,
    Object? sparkBalance = null,
    Object? distance = freezed,
    Object? id = freezed,
    Object? referralCode = freezed,
    Object? referredBy = freezed,
    Object? showOnline = null,
    Object? alwaysMetal = null,
    Object? receiveNotification = null,
    Object? showMyProfile = null,
    Object? activateVoiceNote = null,
    Object? activateVoiceCall = null,
    Object? activateVideoCall = null,
    Object? profilePhoto = freezed,
    Object? fcmToken = freezed,
    Object? isOnline = null,
    Object? lastActive = freezed,
    Object? blockedUsers = freezed,
  }) {
    return _then(_$UserModelImpl(
      profileUpdated: freezed == profileUpdated
          ? _value.profileUpdated
          : profileUpdated // ignore: cast_nullable_to_non_nullable
              as bool?,
      completedProfile: freezed == completedProfile
          ? _value.completedProfile
          : completedProfile // ignore: cast_nullable_to_non_nullable
              as bool?,
      dob: freezed == dob
          ? _value.dob
          : dob // ignore: cast_nullable_to_non_nullable
              as String?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as Address?,
      connectWith: freezed == connectWith
          ? _value.connectWith
          : connectWith // ignore: cast_nullable_to_non_nullable
              as String?,
      connectionOption: freezed == connectionOption
          ? _value._connectionOption
          : connectionOption // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      extraData: freezed == extraData
          ? _value.extraData
          : extraData // ignore: cast_nullable_to_non_nullable
              as ExtraData?,
      fullname: freezed == fullname
          ? _value.fullname
          : fullname // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: freezed == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as String?,
      isVerified: freezed == isVerified
          ? _value.isVerified
          : isVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      isActivated: freezed == isActivated
          ? _value.isActivated
          : isActivated // ignore: cast_nullable_to_non_nullable
              as bool?,
      location: freezed == location
          ? _value.location
          : location // ignore: cast_nullable_to_non_nullable
              as Location?,
      metal: freezed == metal
          ? _value.metal
          : metal // ignore: cast_nullable_to_non_nullable
              as String?,
      passion: freezed == passion
          ? _value._passion
          : passion // ignore: cast_nullable_to_non_nullable
              as List<String>?,
      phone: freezed == phone
          ? _value.phone
          : phone // ignore: cast_nullable_to_non_nullable
              as String?,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      emailVerified: freezed == emailVerified
          ? _value.emailVerified
          : emailVerified // ignore: cast_nullable_to_non_nullable
              as bool?,
      preferences: freezed == preferences
          ? _value.preferences
          : preferences // ignore: cast_nullable_to_non_nullable
              as Preferences?,
      username: freezed == username
          ? _value.username
          : username // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      subscription: freezed == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as SubscribedPlanModel?,
      sparkBalance: null == sparkBalance
          ? _value.sparkBalance
          : sparkBalance // ignore: cast_nullable_to_non_nullable
              as double,
      distance: freezed == distance
          ? _value.distance
          : distance // ignore: cast_nullable_to_non_nullable
              as String?,
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      referralCode: freezed == referralCode
          ? _value.referralCode
          : referralCode // ignore: cast_nullable_to_non_nullable
              as String?,
      referredBy: freezed == referredBy
          ? _value.referredBy
          : referredBy // ignore: cast_nullable_to_non_nullable
              as String?,
      showOnline: null == showOnline
          ? _value.showOnline
          : showOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      alwaysMetal: null == alwaysMetal
          ? _value.alwaysMetal
          : alwaysMetal // ignore: cast_nullable_to_non_nullable
              as bool,
      receiveNotification: null == receiveNotification
          ? _value.receiveNotification
          : receiveNotification // ignore: cast_nullable_to_non_nullable
              as bool,
      showMyProfile: null == showMyProfile
          ? _value.showMyProfile
          : showMyProfile // ignore: cast_nullable_to_non_nullable
              as bool,
      activateVoiceNote: null == activateVoiceNote
          ? _value.activateVoiceNote
          : activateVoiceNote // ignore: cast_nullable_to_non_nullable
              as bool,
      activateVoiceCall: null == activateVoiceCall
          ? _value.activateVoiceCall
          : activateVoiceCall // ignore: cast_nullable_to_non_nullable
              as bool,
      activateVideoCall: null == activateVideoCall
          ? _value.activateVideoCall
          : activateVideoCall // ignore: cast_nullable_to_non_nullable
              as bool,
      profilePhoto: freezed == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      isOnline: null == isOnline
          ? _value.isOnline
          : isOnline // ignore: cast_nullable_to_non_nullable
              as bool,
      lastActive: freezed == lastActive
          ? _value.lastActive
          : lastActive // ignore: cast_nullable_to_non_nullable
              as String?,
      blockedUsers: freezed == blockedUsers
          ? _value._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<String>?,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$UserModelImpl implements _UserModel {
  _$UserModelImpl(
      {this.profileUpdated,
      this.completedProfile,
      this.dob,
      this.address,
      @JsonKey(name: 'connectWith') this.connectWith,
      @JsonKey(name: 'connectionOption') final List<String>? connectionOption,
      this.description,
      @JsonKey(name: 'extraData') this.extraData,
      this.fullname,
      this.gender,
      this.isVerified,
      this.isActivated,
      this.location,
      this.metal,
      final List<String>? passion,
      this.phone,
      this.email,
      this.emailVerified,
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
      this.isOnline = false,
      this.lastActive,
      @JsonKey(name: 'blockedUsers') final List<String>? blockedUsers})
      : _connectionOption = connectionOption,
        _passion = passion,
        _blockedUsers = blockedUsers;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final bool? profileUpdated;
  @override
  final bool? completedProfile;
  @override
  final String? dob;
  @override
  final Address? address;
  @override
  @JsonKey(name: 'connectWith')
  final String? connectWith;
  final List<String>? _connectionOption;
  @override
  @JsonKey(name: 'connectionOption')
  List<String>? get connectionOption {
    final value = _connectionOption;
    if (value == null) return null;
    if (_connectionOption is EqualUnmodifiableListView)
      return _connectionOption;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? description;
  @override
  @JsonKey(name: 'extraData')
  final ExtraData? extraData;
  @override
  final String? fullname;
  @override
  final String? gender;
  @override
  final bool? isVerified;
  @override
  final bool? isActivated;
  @override
  final Location? location;
  @override
  final String? metal;
  final List<String>? _passion;
  @override
  List<String>? get passion {
    final value = _passion;
    if (value == null) return null;
    if (_passion is EqualUnmodifiableListView) return _passion;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final String? phone;
  @override
  final String? email;
  @override
  final bool? emailVerified;
  @override
  final Preferences? preferences;
  @override
  final String? username;
  @override
  final String? refreshToken;
  @override
  final SubscribedPlanModel? subscription;
  @override
  @JsonKey()
  final double sparkBalance;
  @override
  final String? distance;
  @override
  final String? id;
  @override
  final String? referralCode;
  @override
  final String? referredBy;
  @override
  @JsonKey()
  final bool showOnline;
  @override
  @JsonKey()
  final bool alwaysMetal;
  @override
  @JsonKey()
  final bool receiveNotification;
  @override
  @JsonKey()
  final bool showMyProfile;
  @override
  @JsonKey()
  final bool activateVoiceNote;
  @override
  @JsonKey()
  final bool activateVoiceCall;
  @override
  @JsonKey()
  final bool activateVideoCall;
  @override
  final String? profilePhoto;
  @override
  final String? fcmToken;
  @override
  @JsonKey()
  final bool isOnline;
  @override
  final String? lastActive;
  final List<String>? _blockedUsers;
  @override
  @JsonKey(name: 'blockedUsers')
  List<String>? get blockedUsers {
    final value = _blockedUsers;
    if (value == null) return null;
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'UserModel(profileUpdated: $profileUpdated, completedProfile: $completedProfile, dob: $dob, address: $address, connectWith: $connectWith, connectionOption: $connectionOption, description: $description, extraData: $extraData, fullname: $fullname, gender: $gender, isVerified: $isVerified, isActivated: $isActivated, location: $location, metal: $metal, passion: $passion, phone: $phone, email: $email, emailVerified: $emailVerified, preferences: $preferences, username: $username, refreshToken: $refreshToken, subscription: $subscription, sparkBalance: $sparkBalance, distance: $distance, id: $id, referralCode: $referralCode, referredBy: $referredBy, showOnline: $showOnline, alwaysMetal: $alwaysMetal, receiveNotification: $receiveNotification, showMyProfile: $showMyProfile, activateVoiceNote: $activateVoiceNote, activateVoiceCall: $activateVoiceCall, activateVideoCall: $activateVideoCall, profilePhoto: $profilePhoto, fcmToken: $fcmToken, isOnline: $isOnline, lastActive: $lastActive, blockedUsers: $blockedUsers)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.profileUpdated, profileUpdated) ||
                other.profileUpdated == profileUpdated) &&
            (identical(other.completedProfile, completedProfile) ||
                other.completedProfile == completedProfile) &&
            (identical(other.dob, dob) || other.dob == dob) &&
            (identical(other.address, address) || other.address == address) &&
            (identical(other.connectWith, connectWith) ||
                other.connectWith == connectWith) &&
            const DeepCollectionEquality()
                .equals(other._connectionOption, _connectionOption) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.extraData, extraData) ||
                other.extraData == extraData) &&
            (identical(other.fullname, fullname) ||
                other.fullname == fullname) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.isVerified, isVerified) ||
                other.isVerified == isVerified) &&
            (identical(other.isActivated, isActivated) ||
                other.isActivated == isActivated) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.metal, metal) || other.metal == metal) &&
            const DeepCollectionEquality().equals(other._passion, _passion) &&
            (identical(other.phone, phone) || other.phone == phone) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.emailVerified, emailVerified) ||
                other.emailVerified == emailVerified) &&
            (identical(other.preferences, preferences) ||
                other.preferences == preferences) &&
            (identical(other.username, username) ||
                other.username == username) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.subscription, subscription) ||
                other.subscription == subscription) &&
            (identical(other.sparkBalance, sparkBalance) ||
                other.sparkBalance == sparkBalance) &&
            (identical(other.distance, distance) ||
                other.distance == distance) &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.referralCode, referralCode) ||
                other.referralCode == referralCode) &&
            (identical(other.referredBy, referredBy) ||
                other.referredBy == referredBy) &&
            (identical(other.showOnline, showOnline) ||
                other.showOnline == showOnline) &&
            (identical(other.alwaysMetal, alwaysMetal) ||
                other.alwaysMetal == alwaysMetal) &&
            (identical(other.receiveNotification, receiveNotification) ||
                other.receiveNotification == receiveNotification) &&
            (identical(other.showMyProfile, showMyProfile) ||
                other.showMyProfile == showMyProfile) &&
            (identical(other.activateVoiceNote, activateVoiceNote) ||
                other.activateVoiceNote == activateVoiceNote) &&
            (identical(other.activateVoiceCall, activateVoiceCall) ||
                other.activateVoiceCall == activateVoiceCall) &&
            (identical(other.activateVideoCall, activateVideoCall) ||
                other.activateVideoCall == activateVideoCall) &&
            (identical(other.profilePhoto, profilePhoto) ||
                other.profilePhoto == profilePhoto) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.isOnline, isOnline) ||
                other.isOnline == isOnline) &&
            (identical(other.lastActive, lastActive) ||
                other.lastActive == lastActive) &&
            const DeepCollectionEquality()
                .equals(other._blockedUsers, _blockedUsers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hashAll([
        runtimeType,
        profileUpdated,
        completedProfile,
        dob,
        address,
        connectWith,
        const DeepCollectionEquality().hash(_connectionOption),
        description,
        extraData,
        fullname,
        gender,
        isVerified,
        isActivated,
        location,
        metal,
        const DeepCollectionEquality().hash(_passion),
        phone,
        email,
        emailVerified,
        preferences,
        username,
        refreshToken,
        subscription,
        sparkBalance,
        distance,
        id,
        referralCode,
        referredBy,
        showOnline,
        alwaysMetal,
        receiveNotification,
        showMyProfile,
        activateVoiceNote,
        activateVoiceCall,
        activateVideoCall,
        profilePhoto,
        fcmToken,
        isOnline,
        lastActive,
        const DeepCollectionEquality().hash(_blockedUsers)
      ]);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  factory _UserModel(
      {final bool? profileUpdated,
      final bool? completedProfile,
      final String? dob,
      final Address? address,
      @JsonKey(name: 'connectWith') final String? connectWith,
      @JsonKey(name: 'connectionOption') final List<String>? connectionOption,
      final String? description,
      @JsonKey(name: 'extraData') final ExtraData? extraData,
      final String? fullname,
      final String? gender,
      final bool? isVerified,
      final bool? isActivated,
      final Location? location,
      final String? metal,
      final List<String>? passion,
      final String? phone,
      final String? email,
      final bool? emailVerified,
      final Preferences? preferences,
      final String? username,
      final String? refreshToken,
      final SubscribedPlanModel? subscription,
      final double sparkBalance,
      final String? distance,
      final String? id,
      final String? referralCode,
      final String? referredBy,
      final bool showOnline,
      final bool alwaysMetal,
      final bool receiveNotification,
      final bool showMyProfile,
      final bool activateVoiceNote,
      final bool activateVoiceCall,
      final bool activateVideoCall,
      final String? profilePhoto,
      final String? fcmToken,
      final bool isOnline,
      final String? lastActive,
      @JsonKey(name: 'blockedUsers')
      final List<String>? blockedUsers}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  bool? get profileUpdated;
  @override
  bool? get completedProfile;
  @override
  String? get dob;
  @override
  Address? get address;
  @override
  @JsonKey(name: 'connectWith')
  String? get connectWith;
  @override
  @JsonKey(name: 'connectionOption')
  List<String>? get connectionOption;
  @override
  String? get description;
  @override
  @JsonKey(name: 'extraData')
  ExtraData? get extraData;
  @override
  String? get fullname;
  @override
  String? get gender;
  @override
  bool? get isVerified;
  @override
  bool? get isActivated;
  @override
  Location? get location;
  @override
  String? get metal;
  @override
  List<String>? get passion;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  bool? get emailVerified;
  @override
  Preferences? get preferences;
  @override
  String? get username;
  @override
  String? get refreshToken;
  @override
  SubscribedPlanModel? get subscription;
  @override
  double get sparkBalance;
  @override
  String? get distance;
  @override
  String? get id;
  @override
  String? get referralCode;
  @override
  String? get referredBy;
  @override
  bool get showOnline;
  @override
  bool get alwaysMetal;
  @override
  bool get receiveNotification;
  @override
  bool get showMyProfile;
  @override
  bool get activateVoiceNote;
  @override
  bool get activateVoiceCall;
  @override
  bool get activateVideoCall;
  @override
  String? get profilePhoto;
  @override
  String? get fcmToken;
  @override
  bool get isOnline;
  @override
  String? get lastActive;
  @override
  @JsonKey(name: 'blockedUsers')
  List<String>? get blockedUsers;
  @override
  @JsonKey(ignore: true)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Address _$AddressFromJson(Map<String, dynamic> json) {
  return _Address.fromJson(json);
}

/// @nodoc
mixin _$Address {
  @JsonKey(name: 'apartmentNumber')
  String? get apartmentNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'houseNumber')
  String? get houseNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'streetName')
  String? get streetName => throw _privateConstructorUsedError;
  @JsonKey(name: 'postalCode')
  String? get postalCode => throw _privateConstructorUsedError;
  String? get state => throw _privateConstructorUsedError;
  String? get country => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $AddressCopyWith<Address> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AddressCopyWith<$Res> {
  factory $AddressCopyWith(Address value, $Res Function(Address) then) =
      _$AddressCopyWithImpl<$Res, Address>;
  @useResult
  $Res call(
      {@JsonKey(name: 'apartmentNumber') String? apartmentNumber,
      @JsonKey(name: 'houseNumber') String? houseNumber,
      @JsonKey(name: 'streetName') String? streetName,
      @JsonKey(name: 'postalCode') String? postalCode,
      String? state,
      String? country});
}

/// @nodoc
class _$AddressCopyWithImpl<$Res, $Val extends Address>
    implements $AddressCopyWith<$Res> {
  _$AddressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apartmentNumber = freezed,
    Object? houseNumber = freezed,
    Object? streetName = freezed,
    Object? postalCode = freezed,
    Object? state = freezed,
    Object? country = freezed,
  }) {
    return _then(_value.copyWith(
      apartmentNumber: freezed == apartmentNumber
          ? _value.apartmentNumber
          : apartmentNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      houseNumber: freezed == houseNumber
          ? _value.houseNumber
          : houseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      streetName: freezed == streetName
          ? _value.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$AddressImplCopyWith<$Res> implements $AddressCopyWith<$Res> {
  factory _$$AddressImplCopyWith(
          _$AddressImpl value, $Res Function(_$AddressImpl) then) =
      __$$AddressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'apartmentNumber') String? apartmentNumber,
      @JsonKey(name: 'houseNumber') String? houseNumber,
      @JsonKey(name: 'streetName') String? streetName,
      @JsonKey(name: 'postalCode') String? postalCode,
      String? state,
      String? country});
}

/// @nodoc
class __$$AddressImplCopyWithImpl<$Res>
    extends _$AddressCopyWithImpl<$Res, _$AddressImpl>
    implements _$$AddressImplCopyWith<$Res> {
  __$$AddressImplCopyWithImpl(
      _$AddressImpl _value, $Res Function(_$AddressImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? apartmentNumber = freezed,
    Object? houseNumber = freezed,
    Object? streetName = freezed,
    Object? postalCode = freezed,
    Object? state = freezed,
    Object? country = freezed,
  }) {
    return _then(_$AddressImpl(
      apartmentNumber: freezed == apartmentNumber
          ? _value.apartmentNumber
          : apartmentNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      houseNumber: freezed == houseNumber
          ? _value.houseNumber
          : houseNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      streetName: freezed == streetName
          ? _value.streetName
          : streetName // ignore: cast_nullable_to_non_nullable
              as String?,
      postalCode: freezed == postalCode
          ? _value.postalCode
          : postalCode // ignore: cast_nullable_to_non_nullable
              as String?,
      state: freezed == state
          ? _value.state
          : state // ignore: cast_nullable_to_non_nullable
              as String?,
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AddressImpl implements _Address {
  _$AddressImpl(
      {@JsonKey(name: 'apartmentNumber') this.apartmentNumber,
      @JsonKey(name: 'houseNumber') this.houseNumber,
      @JsonKey(name: 'streetName') this.streetName,
      @JsonKey(name: 'postalCode') this.postalCode,
      this.state,
      this.country});

  factory _$AddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressImplFromJson(json);

  @override
  @JsonKey(name: 'apartmentNumber')
  final String? apartmentNumber;
  @override
  @JsonKey(name: 'houseNumber')
  final String? houseNumber;
  @override
  @JsonKey(name: 'streetName')
  final String? streetName;
  @override
  @JsonKey(name: 'postalCode')
  final String? postalCode;
  @override
  final String? state;
  @override
  final String? country;

  @override
  String toString() {
    return 'Address(apartmentNumber: $apartmentNumber, houseNumber: $houseNumber, streetName: $streetName, postalCode: $postalCode, state: $state, country: $country)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AddressImpl &&
            (identical(other.apartmentNumber, apartmentNumber) ||
                other.apartmentNumber == apartmentNumber) &&
            (identical(other.houseNumber, houseNumber) ||
                other.houseNumber == houseNumber) &&
            (identical(other.streetName, streetName) ||
                other.streetName == streetName) &&
            (identical(other.postalCode, postalCode) ||
                other.postalCode == postalCode) &&
            (identical(other.state, state) || other.state == state) &&
            (identical(other.country, country) || other.country == country));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, apartmentNumber, houseNumber,
      streetName, postalCode, state, country);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      __$$AddressImplCopyWithImpl<_$AddressImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AddressImplToJson(
      this,
    );
  }
}

abstract class _Address implements Address {
  factory _Address(
      {@JsonKey(name: 'apartmentNumber') final String? apartmentNumber,
      @JsonKey(name: 'houseNumber') final String? houseNumber,
      @JsonKey(name: 'streetName') final String? streetName,
      @JsonKey(name: 'postalCode') final String? postalCode,
      final String? state,
      final String? country}) = _$AddressImpl;

  factory _Address.fromJson(Map<String, dynamic> json) = _$AddressImpl.fromJson;

  @override
  @JsonKey(name: 'apartmentNumber')
  String? get apartmentNumber;
  @override
  @JsonKey(name: 'houseNumber')
  String? get houseNumber;
  @override
  @JsonKey(name: 'streetName')
  String? get streetName;
  @override
  @JsonKey(name: 'postalCode')
  String? get postalCode;
  @override
  String? get state;
  @override
  String? get country;
  @override
  @JsonKey(ignore: true)
  _$$AddressImplCopyWith<_$AddressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ExtraData _$ExtraDataFromJson(Map<String, dynamic> json) {
  return _ExtraData.fromJson(json);
}

/// @nodoc
mixin _$ExtraData {
  String? get country => throw _privateConstructorUsedError;
  String? get education => throw _privateConstructorUsedError;
  String? get ethnicity => throw _privateConstructorUsedError;
  String? get language => throw _privateConstructorUsedError;
  @JsonKey(name: 'maritalStatus')
  String? get maritalStatus => throw _privateConstructorUsedError;
  String? get profession => throw _privateConstructorUsedError;
  String? get religion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ExtraDataCopyWith<ExtraData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ExtraDataCopyWith<$Res> {
  factory $ExtraDataCopyWith(ExtraData value, $Res Function(ExtraData) then) =
      _$ExtraDataCopyWithImpl<$Res, ExtraData>;
  @useResult
  $Res call(
      {String? country,
      String? education,
      String? ethnicity,
      String? language,
      @JsonKey(name: 'maritalStatus') String? maritalStatus,
      String? profession,
      String? religion});
}

/// @nodoc
class _$ExtraDataCopyWithImpl<$Res, $Val extends ExtraData>
    implements $ExtraDataCopyWith<$Res> {
  _$ExtraDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = freezed,
    Object? education = freezed,
    Object? ethnicity = freezed,
    Object? language = freezed,
    Object? maritalStatus = freezed,
    Object? profession = freezed,
    Object? religion = freezed,
  }) {
    return _then(_value.copyWith(
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      education: freezed == education
          ? _value.education
          : education // ignore: cast_nullable_to_non_nullable
              as String?,
      ethnicity: freezed == ethnicity
          ? _value.ethnicity
          : ethnicity // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      maritalStatus: freezed == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      profession: freezed == profession
          ? _value.profession
          : profession // ignore: cast_nullable_to_non_nullable
              as String?,
      religion: freezed == religion
          ? _value.religion
          : religion // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ExtraDataImplCopyWith<$Res>
    implements $ExtraDataCopyWith<$Res> {
  factory _$$ExtraDataImplCopyWith(
          _$ExtraDataImpl value, $Res Function(_$ExtraDataImpl) then) =
      __$$ExtraDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String? country,
      String? education,
      String? ethnicity,
      String? language,
      @JsonKey(name: 'maritalStatus') String? maritalStatus,
      String? profession,
      String? religion});
}

/// @nodoc
class __$$ExtraDataImplCopyWithImpl<$Res>
    extends _$ExtraDataCopyWithImpl<$Res, _$ExtraDataImpl>
    implements _$$ExtraDataImplCopyWith<$Res> {
  __$$ExtraDataImplCopyWithImpl(
      _$ExtraDataImpl _value, $Res Function(_$ExtraDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? country = freezed,
    Object? education = freezed,
    Object? ethnicity = freezed,
    Object? language = freezed,
    Object? maritalStatus = freezed,
    Object? profession = freezed,
    Object? religion = freezed,
  }) {
    return _then(_$ExtraDataImpl(
      country: freezed == country
          ? _value.country
          : country // ignore: cast_nullable_to_non_nullable
              as String?,
      education: freezed == education
          ? _value.education
          : education // ignore: cast_nullable_to_non_nullable
              as String?,
      ethnicity: freezed == ethnicity
          ? _value.ethnicity
          : ethnicity // ignore: cast_nullable_to_non_nullable
              as String?,
      language: freezed == language
          ? _value.language
          : language // ignore: cast_nullable_to_non_nullable
              as String?,
      maritalStatus: freezed == maritalStatus
          ? _value.maritalStatus
          : maritalStatus // ignore: cast_nullable_to_non_nullable
              as String?,
      profession: freezed == profession
          ? _value.profession
          : profession // ignore: cast_nullable_to_non_nullable
              as String?,
      religion: freezed == religion
          ? _value.religion
          : religion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ExtraDataImpl implements _ExtraData {
  _$ExtraDataImpl(
      {this.country,
      this.education,
      this.ethnicity,
      this.language,
      @JsonKey(name: 'maritalStatus') this.maritalStatus,
      this.profession,
      this.religion});

  factory _$ExtraDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$ExtraDataImplFromJson(json);

  @override
  final String? country;
  @override
  final String? education;
  @override
  final String? ethnicity;
  @override
  final String? language;
  @override
  @JsonKey(name: 'maritalStatus')
  final String? maritalStatus;
  @override
  final String? profession;
  @override
  final String? religion;

  @override
  String toString() {
    return 'ExtraData(country: $country, education: $education, ethnicity: $ethnicity, language: $language, maritalStatus: $maritalStatus, profession: $profession, religion: $religion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ExtraDataImpl &&
            (identical(other.country, country) || other.country == country) &&
            (identical(other.education, education) ||
                other.education == education) &&
            (identical(other.ethnicity, ethnicity) ||
                other.ethnicity == ethnicity) &&
            (identical(other.language, language) ||
                other.language == language) &&
            (identical(other.maritalStatus, maritalStatus) ||
                other.maritalStatus == maritalStatus) &&
            (identical(other.profession, profession) ||
                other.profession == profession) &&
            (identical(other.religion, religion) ||
                other.religion == religion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, country, education, ethnicity,
      language, maritalStatus, profession, religion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ExtraDataImplCopyWith<_$ExtraDataImpl> get copyWith =>
      __$$ExtraDataImplCopyWithImpl<_$ExtraDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ExtraDataImplToJson(
      this,
    );
  }
}

abstract class _ExtraData implements ExtraData {
  factory _ExtraData(
      {final String? country,
      final String? education,
      final String? ethnicity,
      final String? language,
      @JsonKey(name: 'maritalStatus') final String? maritalStatus,
      final String? profession,
      final String? religion}) = _$ExtraDataImpl;

  factory _ExtraData.fromJson(Map<String, dynamic> json) =
      _$ExtraDataImpl.fromJson;

  @override
  String? get country;
  @override
  String? get education;
  @override
  String? get ethnicity;
  @override
  String? get language;
  @override
  @JsonKey(name: 'maritalStatus')
  String? get maritalStatus;
  @override
  String? get profession;
  @override
  String? get religion;
  @override
  @JsonKey(ignore: true)
  _$$ExtraDataImplCopyWith<_$ExtraDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Preferences _$PreferencesFromJson(Map<String, dynamic> json) {
  return _Preferences.fromJson(json);
}

/// @nodoc
mixin _$Preferences {
  @JsonKey(name: 'ageRange')
  String? get ageRange => throw _privateConstructorUsedError;
  String? get demography => throw _privateConstructorUsedError;
  String? get education => throw _privateConstructorUsedError;
  String? get ethnicity => throw _privateConstructorUsedError;
  String? get religion => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $PreferencesCopyWith<Preferences> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PreferencesCopyWith<$Res> {
  factory $PreferencesCopyWith(
          Preferences value, $Res Function(Preferences) then) =
      _$PreferencesCopyWithImpl<$Res, Preferences>;
  @useResult
  $Res call(
      {@JsonKey(name: 'ageRange') String? ageRange,
      String? demography,
      String? education,
      String? ethnicity,
      String? religion});
}

/// @nodoc
class _$PreferencesCopyWithImpl<$Res, $Val extends Preferences>
    implements $PreferencesCopyWith<$Res> {
  _$PreferencesCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ageRange = freezed,
    Object? demography = freezed,
    Object? education = freezed,
    Object? ethnicity = freezed,
    Object? religion = freezed,
  }) {
    return _then(_value.copyWith(
      ageRange: freezed == ageRange
          ? _value.ageRange
          : ageRange // ignore: cast_nullable_to_non_nullable
              as String?,
      demography: freezed == demography
          ? _value.demography
          : demography // ignore: cast_nullable_to_non_nullable
              as String?,
      education: freezed == education
          ? _value.education
          : education // ignore: cast_nullable_to_non_nullable
              as String?,
      ethnicity: freezed == ethnicity
          ? _value.ethnicity
          : ethnicity // ignore: cast_nullable_to_non_nullable
              as String?,
      religion: freezed == religion
          ? _value.religion
          : religion // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PreferencesImplCopyWith<$Res>
    implements $PreferencesCopyWith<$Res> {
  factory _$$PreferencesImplCopyWith(
          _$PreferencesImpl value, $Res Function(_$PreferencesImpl) then) =
      __$$PreferencesImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {@JsonKey(name: 'ageRange') String? ageRange,
      String? demography,
      String? education,
      String? ethnicity,
      String? religion});
}

/// @nodoc
class __$$PreferencesImplCopyWithImpl<$Res>
    extends _$PreferencesCopyWithImpl<$Res, _$PreferencesImpl>
    implements _$$PreferencesImplCopyWith<$Res> {
  __$$PreferencesImplCopyWithImpl(
      _$PreferencesImpl _value, $Res Function(_$PreferencesImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ageRange = freezed,
    Object? demography = freezed,
    Object? education = freezed,
    Object? ethnicity = freezed,
    Object? religion = freezed,
  }) {
    return _then(_$PreferencesImpl(
      ageRange: freezed == ageRange
          ? _value.ageRange
          : ageRange // ignore: cast_nullable_to_non_nullable
              as String?,
      demography: freezed == demography
          ? _value.demography
          : demography // ignore: cast_nullable_to_non_nullable
              as String?,
      education: freezed == education
          ? _value.education
          : education // ignore: cast_nullable_to_non_nullable
              as String?,
      ethnicity: freezed == ethnicity
          ? _value.ethnicity
          : ethnicity // ignore: cast_nullable_to_non_nullable
              as String?,
      religion: freezed == religion
          ? _value.religion
          : religion // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PreferencesImpl implements _Preferences {
  _$PreferencesImpl(
      {@JsonKey(name: 'ageRange') this.ageRange,
      this.demography,
      this.education,
      this.ethnicity,
      this.religion});

  factory _$PreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferencesImplFromJson(json);

  @override
  @JsonKey(name: 'ageRange')
  final String? ageRange;
  @override
  final String? demography;
  @override
  final String? education;
  @override
  final String? ethnicity;
  @override
  final String? religion;

  @override
  String toString() {
    return 'Preferences(ageRange: $ageRange, demography: $demography, education: $education, ethnicity: $ethnicity, religion: $religion)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PreferencesImpl &&
            (identical(other.ageRange, ageRange) ||
                other.ageRange == ageRange) &&
            (identical(other.demography, demography) ||
                other.demography == demography) &&
            (identical(other.education, education) ||
                other.education == education) &&
            (identical(other.ethnicity, ethnicity) ||
                other.ethnicity == ethnicity) &&
            (identical(other.religion, religion) ||
                other.religion == religion));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, ageRange, demography, education, ethnicity, religion);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      __$$PreferencesImplCopyWithImpl<_$PreferencesImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PreferencesImplToJson(
      this,
    );
  }
}

abstract class _Preferences implements Preferences {
  factory _Preferences(
      {@JsonKey(name: 'ageRange') final String? ageRange,
      final String? demography,
      final String? education,
      final String? ethnicity,
      final String? religion}) = _$PreferencesImpl;

  factory _Preferences.fromJson(Map<String, dynamic> json) =
      _$PreferencesImpl.fromJson;

  @override
  @JsonKey(name: 'ageRange')
  String? get ageRange;
  @override
  String? get demography;
  @override
  String? get education;
  @override
  String? get ethnicity;
  @override
  String? get religion;
  @override
  @JsonKey(ignore: true)
  _$$PreferencesImplCopyWith<_$PreferencesImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

Location _$LocationFromJson(Map<String, dynamic> json) {
  return _Location.fromJson(json);
}

/// @nodoc
mixin _$Location {
  double? get lat => throw _privateConstructorUsedError;
  double? get lng => throw _privateConstructorUsedError;
  String? get address => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $LocationCopyWith<Location> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LocationCopyWith<$Res> {
  factory $LocationCopyWith(Location value, $Res Function(Location) then) =
      _$LocationCopyWithImpl<$Res, Location>;
  @useResult
  $Res call({double? lat, double? lng, String? address});
}

/// @nodoc
class _$LocationCopyWithImpl<$Res, $Val extends Location>
    implements $LocationCopyWith<$Res> {
  _$LocationCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = freezed,
    Object? lng = freezed,
    Object? address = freezed,
  }) {
    return _then(_value.copyWith(
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$LocationImplCopyWith<$Res>
    implements $LocationCopyWith<$Res> {
  factory _$$LocationImplCopyWith(
          _$LocationImpl value, $Res Function(_$LocationImpl) then) =
      __$$LocationImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({double? lat, double? lng, String? address});
}

/// @nodoc
class __$$LocationImplCopyWithImpl<$Res>
    extends _$LocationCopyWithImpl<$Res, _$LocationImpl>
    implements _$$LocationImplCopyWith<$Res> {
  __$$LocationImplCopyWithImpl(
      _$LocationImpl _value, $Res Function(_$LocationImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lat = freezed,
    Object? lng = freezed,
    Object? address = freezed,
  }) {
    return _then(_$LocationImpl(
      lat: freezed == lat
          ? _value.lat
          : lat // ignore: cast_nullable_to_non_nullable
              as double?,
      lng: freezed == lng
          ? _value.lng
          : lng // ignore: cast_nullable_to_non_nullable
              as double?,
      address: freezed == address
          ? _value.address
          : address // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$LocationImpl implements _Location {
  _$LocationImpl({this.lat, this.lng, this.address});

  factory _$LocationImpl.fromJson(Map<String, dynamic> json) =>
      _$$LocationImplFromJson(json);

  @override
  final double? lat;
  @override
  final double? lng;
  @override
  final String? address;

  @override
  String toString() {
    return 'Location(lat: $lat, lng: $lng, address: $address)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LocationImpl &&
            (identical(other.lat, lat) || other.lat == lat) &&
            (identical(other.lng, lng) || other.lng == lng) &&
            (identical(other.address, address) || other.address == address));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, lat, lng, address);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      __$$LocationImplCopyWithImpl<_$LocationImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$LocationImplToJson(
      this,
    );
  }
}

abstract class _Location implements Location {
  factory _Location(
      {final double? lat,
      final double? lng,
      final String? address}) = _$LocationImpl;

  factory _Location.fromJson(Map<String, dynamic> json) =
      _$LocationImpl.fromJson;

  @override
  double? get lat;
  @override
  double? get lng;
  @override
  String? get address;
  @override
  @JsonKey(ignore: true)
  _$$LocationImplCopyWith<_$LocationImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
