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
  @JsonKey(name: 'profile_updated')
  bool? get profileUpdated => throw _privateConstructorUsedError;
  @JsonKey(name: 'completed_profile')
  bool? get completedProfile => throw _privateConstructorUsedError;
  @JsonKey(name: 'DOB')
  String? get dob => throw _privateConstructorUsedError;
  Address? get address => throw _privateConstructorUsedError;
  @JsonKey(name: 'connect_with')
  String? get connectWith => throw _privateConstructorUsedError;
  @JsonKey(name: 'connection_option')
  List<String>? get connectionOption => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'extra_data')
  ExtraData? get extraData => throw _privateConstructorUsedError;
  String? get fullname => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'isVerified')
  bool? get isVerified => throw _privateConstructorUsedError;
  @JsonKey(name: 'isActivated')
  bool? get isActivated => throw _privateConstructorUsedError;
  Location? get location => throw _privateConstructorUsedError;
  Metal? get metal => throw _privateConstructorUsedError;
  List<String>? get passion => throw _privateConstructorUsedError;
  String? get phone => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: 'email_verified')
  bool? get emailVerified => throw _privateConstructorUsedError;
  Preferences? get preferences => throw _privateConstructorUsedError;
  String? get username => throw _privateConstructorUsedError;
  @JsonKey(name: 'access_token')
  String? get accessToken => throw _privateConstructorUsedError;
  String? get refreshToken => throw _privateConstructorUsedError;
  SubscribedPlanModel? get subscription => throw _privateConstructorUsedError;
  double? get sparkBalance => throw _privateConstructorUsedError;
  String? get distance => throw _privateConstructorUsedError;
  String? get id => throw _privateConstructorUsedError;
  String? get referralCode => throw _privateConstructorUsedError;
  String? get profilePhoto => throw _privateConstructorUsedError;
  String? get fcmToken => throw _privateConstructorUsedError;
  String? get conversationId => throw _privateConstructorUsedError;
  @JsonKey(name: 'blockedUsers')
  List<BlockedUser>? get blockedUsers => throw _privateConstructorUsedError;

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
      {@JsonKey(name: 'profile_updated') bool? profileUpdated,
      @JsonKey(name: 'completed_profile') bool? completedProfile,
      @JsonKey(name: 'DOB') String? dob,
      Address? address,
      @JsonKey(name: 'connect_with') String? connectWith,
      @JsonKey(name: 'connection_option') List<String>? connectionOption,
      String? description,
      @JsonKey(name: 'extra_data') ExtraData? extraData,
      String? fullname,
      String? gender,
      @JsonKey(name: 'isVerified') bool? isVerified,
      @JsonKey(name: 'isActivated') bool? isActivated,
      Location? location,
      Metal? metal,
      List<String>? passion,
      String? phone,
      String? email,
      @JsonKey(name: 'email_verified') bool? emailVerified,
      Preferences? preferences,
      String? username,
      @JsonKey(name: 'access_token') String? accessToken,
      String? refreshToken,
      SubscribedPlanModel? subscription,
      double? sparkBalance,
      String? distance,
      String? id,
      String? referralCode,
      String? profilePhoto,
      String? fcmToken,
      String? conversationId,
      @JsonKey(name: 'blockedUsers') List<BlockedUser>? blockedUsers});

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
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? subscription = freezed,
    Object? sparkBalance = freezed,
    Object? distance = freezed,
    Object? id = freezed,
    Object? referralCode = freezed,
    Object? profilePhoto = freezed,
    Object? fcmToken = freezed,
    Object? conversationId = freezed,
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
              as Metal?,
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
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      subscription: freezed == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as SubscribedPlanModel?,
      sparkBalance: freezed == sparkBalance
          ? _value.sparkBalance
          : sparkBalance // ignore: cast_nullable_to_non_nullable
              as double?,
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
      profilePhoto: freezed == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      conversationId: freezed == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String?,
      blockedUsers: freezed == blockedUsers
          ? _value.blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<BlockedUser>?,
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
      {@JsonKey(name: 'profile_updated') bool? profileUpdated,
      @JsonKey(name: 'completed_profile') bool? completedProfile,
      @JsonKey(name: 'DOB') String? dob,
      Address? address,
      @JsonKey(name: 'connect_with') String? connectWith,
      @JsonKey(name: 'connection_option') List<String>? connectionOption,
      String? description,
      @JsonKey(name: 'extra_data') ExtraData? extraData,
      String? fullname,
      String? gender,
      @JsonKey(name: 'isVerified') bool? isVerified,
      @JsonKey(name: 'isActivated') bool? isActivated,
      Location? location,
      Metal? metal,
      List<String>? passion,
      String? phone,
      String? email,
      @JsonKey(name: 'email_verified') bool? emailVerified,
      Preferences? preferences,
      String? username,
      @JsonKey(name: 'access_token') String? accessToken,
      String? refreshToken,
      SubscribedPlanModel? subscription,
      double? sparkBalance,
      String? distance,
      String? id,
      String? referralCode,
      String? profilePhoto,
      String? fcmToken,
      String? conversationId,
      @JsonKey(name: 'blockedUsers') List<BlockedUser>? blockedUsers});

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
    Object? accessToken = freezed,
    Object? refreshToken = freezed,
    Object? subscription = freezed,
    Object? sparkBalance = freezed,
    Object? distance = freezed,
    Object? id = freezed,
    Object? referralCode = freezed,
    Object? profilePhoto = freezed,
    Object? fcmToken = freezed,
    Object? conversationId = freezed,
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
              as Metal?,
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
      accessToken: freezed == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String?,
      refreshToken: freezed == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String?,
      subscription: freezed == subscription
          ? _value.subscription
          : subscription // ignore: cast_nullable_to_non_nullable
              as SubscribedPlanModel?,
      sparkBalance: freezed == sparkBalance
          ? _value.sparkBalance
          : sparkBalance // ignore: cast_nullable_to_non_nullable
              as double?,
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
      profilePhoto: freezed == profilePhoto
          ? _value.profilePhoto
          : profilePhoto // ignore: cast_nullable_to_non_nullable
              as String?,
      fcmToken: freezed == fcmToken
          ? _value.fcmToken
          : fcmToken // ignore: cast_nullable_to_non_nullable
              as String?,
      conversationId: freezed == conversationId
          ? _value.conversationId
          : conversationId // ignore: cast_nullable_to_non_nullable
              as String?,
      blockedUsers: freezed == blockedUsers
          ? _value._blockedUsers
          : blockedUsers // ignore: cast_nullable_to_non_nullable
              as List<BlockedUser>?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  _$UserModelImpl(
      {@JsonKey(name: 'profile_updated') this.profileUpdated,
      @JsonKey(name: 'completed_profile') this.completedProfile,
      @JsonKey(name: 'DOB') this.dob,
      this.address,
      @JsonKey(name: 'connect_with') this.connectWith,
      @JsonKey(name: 'connection_option') final List<String>? connectionOption,
      this.description,
      @JsonKey(name: 'extra_data') this.extraData,
      this.fullname,
      this.gender,
      @JsonKey(name: 'isVerified') this.isVerified,
      @JsonKey(name: 'isActivated') this.isActivated,
      this.location,
      this.metal,
      final List<String>? passion,
      this.phone,
      this.email,
      @JsonKey(name: 'email_verified') this.emailVerified,
      this.preferences,
      this.username,
      @JsonKey(name: 'access_token') this.accessToken,
      this.refreshToken,
      this.subscription,
      this.sparkBalance,
      this.distance,
      this.id,
      this.referralCode,
      this.profilePhoto,
      this.fcmToken,
      this.conversationId,
      @JsonKey(name: 'blockedUsers') final List<BlockedUser>? blockedUsers})
      : _connectionOption = connectionOption,
        _passion = passion,
        _blockedUsers = blockedUsers;

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  @JsonKey(name: 'profile_updated')
  final bool? profileUpdated;
  @override
  @JsonKey(name: 'completed_profile')
  final bool? completedProfile;
  @override
  @JsonKey(name: 'DOB')
  final String? dob;
  @override
  final Address? address;
  @override
  @JsonKey(name: 'connect_with')
  final String? connectWith;
  final List<String>? _connectionOption;
  @override
  @JsonKey(name: 'connection_option')
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
  @JsonKey(name: 'extra_data')
  final ExtraData? extraData;
  @override
  final String? fullname;
  @override
  final String? gender;
  @override
  @JsonKey(name: 'isVerified')
  final bool? isVerified;
  @override
  @JsonKey(name: 'isActivated')
  final bool? isActivated;
  @override
  final Location? location;
  @override
  final Metal? metal;
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
  @JsonKey(name: 'email_verified')
  final bool? emailVerified;
  @override
  final Preferences? preferences;
  @override
  final String? username;
  @override
  @JsonKey(name: 'access_token')
  final String? accessToken;
  @override
  final String? refreshToken;
  @override
  final SubscribedPlanModel? subscription;
  @override
  final double? sparkBalance;
  @override
  final String? distance;
  @override
  final String? id;
  @override
  final String? referralCode;
  @override
  final String? profilePhoto;
  @override
  final String? fcmToken;
  @override
  final String? conversationId;
  final List<BlockedUser>? _blockedUsers;
  @override
  @JsonKey(name: 'blockedUsers')
  List<BlockedUser>? get blockedUsers {
    final value = _blockedUsers;
    if (value == null) return null;
    if (_blockedUsers is EqualUnmodifiableListView) return _blockedUsers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  String toString() {
    return 'UserModel(profileUpdated: $profileUpdated, completedProfile: $completedProfile, dob: $dob, address: $address, connectWith: $connectWith, connectionOption: $connectionOption, description: $description, extraData: $extraData, fullname: $fullname, gender: $gender, isVerified: $isVerified, isActivated: $isActivated, location: $location, metal: $metal, passion: $passion, phone: $phone, email: $email, emailVerified: $emailVerified, preferences: $preferences, username: $username, accessToken: $accessToken, refreshToken: $refreshToken, subscription: $subscription, sparkBalance: $sparkBalance, distance: $distance, id: $id, referralCode: $referralCode, profilePhoto: $profilePhoto, fcmToken: $fcmToken, conversationId: $conversationId, blockedUsers: $blockedUsers)';
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
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
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
            (identical(other.profilePhoto, profilePhoto) ||
                other.profilePhoto == profilePhoto) &&
            (identical(other.fcmToken, fcmToken) ||
                other.fcmToken == fcmToken) &&
            (identical(other.conversationId, conversationId) ||
                other.conversationId == conversationId) &&
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
        accessToken,
        refreshToken,
        subscription,
        sparkBalance,
        distance,
        id,
        referralCode,
        profilePhoto,
        fcmToken,
        conversationId,
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
      {@JsonKey(name: 'profile_updated') final bool? profileUpdated,
      @JsonKey(name: 'completed_profile') final bool? completedProfile,
      @JsonKey(name: 'DOB') final String? dob,
      final Address? address,
      @JsonKey(name: 'connect_with') final String? connectWith,
      @JsonKey(name: 'connection_option') final List<String>? connectionOption,
      final String? description,
      @JsonKey(name: 'extra_data') final ExtraData? extraData,
      final String? fullname,
      final String? gender,
      @JsonKey(name: 'isVerified') final bool? isVerified,
      @JsonKey(name: 'isActivated') final bool? isActivated,
      final Location? location,
      final Metal? metal,
      final List<String>? passion,
      final String? phone,
      final String? email,
      @JsonKey(name: 'email_verified') final bool? emailVerified,
      final Preferences? preferences,
      final String? username,
      @JsonKey(name: 'access_token') final String? accessToken,
      final String? refreshToken,
      final SubscribedPlanModel? subscription,
      final double? sparkBalance,
      final String? distance,
      final String? id,
      final String? referralCode,
      final String? profilePhoto,
      final String? fcmToken,
      final String? conversationId,
      @JsonKey(name: 'blockedUsers')
      final List<BlockedUser>? blockedUsers}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  @JsonKey(name: 'profile_updated')
  bool? get profileUpdated;
  @override
  @JsonKey(name: 'completed_profile')
  bool? get completedProfile;
  @override
  @JsonKey(name: 'DOB')
  String? get dob;
  @override
  Address? get address;
  @override
  @JsonKey(name: 'connect_with')
  String? get connectWith;
  @override
  @JsonKey(name: 'connection_option')
  List<String>? get connectionOption;
  @override
  String? get description;
  @override
  @JsonKey(name: 'extra_data')
  ExtraData? get extraData;
  @override
  String? get fullname;
  @override
  String? get gender;
  @override
  @JsonKey(name: 'isVerified')
  bool? get isVerified;
  @override
  @JsonKey(name: 'isActivated')
  bool? get isActivated;
  @override
  Location? get location;
  @override
  Metal? get metal;
  @override
  List<String>? get passion;
  @override
  String? get phone;
  @override
  String? get email;
  @override
  @JsonKey(name: 'email_verified')
  bool? get emailVerified;
  @override
  Preferences? get preferences;
  @override
  String? get username;
  @override
  @JsonKey(name: 'access_token')
  String? get accessToken;
  @override
  String? get refreshToken;
  @override
  SubscribedPlanModel? get subscription;
  @override
  double? get sparkBalance;
  @override
  String? get distance;
  @override
  String? get id;
  @override
  String? get referralCode;
  @override
  String? get profilePhoto;
  @override
  String? get fcmToken;
  @override
  String? get conversationId;
  @override
  @JsonKey(name: 'blockedUsers')
  List<BlockedUser>? get blockedUsers;
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
  @JsonKey(name: 'apartment_number')
  String? get apartmentNumber => throw _privateConstructorUsedError;
  @JsonKey(name: 'house_number')
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
      {@JsonKey(name: 'apartment_number') String? apartmentNumber,
      @JsonKey(name: 'house_number') String? houseNumber,
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
      {@JsonKey(name: 'apartment_number') String? apartmentNumber,
      @JsonKey(name: 'house_number') String? houseNumber,
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
      {@JsonKey(name: 'apartment_number') this.apartmentNumber,
      @JsonKey(name: 'house_number') this.houseNumber,
      @JsonKey(name: 'streetName') this.streetName,
      @JsonKey(name: 'postalCode') this.postalCode,
      this.state,
      this.country});

  factory _$AddressImpl.fromJson(Map<String, dynamic> json) =>
      _$$AddressImplFromJson(json);

  @override
  @JsonKey(name: 'apartment_number')
  final String? apartmentNumber;
  @override
  @JsonKey(name: 'house_number')
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
      {@JsonKey(name: 'apartment_number') final String? apartmentNumber,
      @JsonKey(name: 'house_number') final String? houseNumber,
      @JsonKey(name: 'streetName') final String? streetName,
      @JsonKey(name: 'postalCode') final String? postalCode,
      final String? state,
      final String? country}) = _$AddressImpl;

  factory _Address.fromJson(Map<String, dynamic> json) = _$AddressImpl.fromJson;

  @override
  @JsonKey(name: 'apartment_number')
  String? get apartmentNumber;
  @override
  @JsonKey(name: 'house_number')
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
  @JsonKey(name: 'marital_status')
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
      @JsonKey(name: 'marital_status') String? maritalStatus,
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
      @JsonKey(name: 'marital_status') String? maritalStatus,
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
      @JsonKey(name: 'marital_status') this.maritalStatus,
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
  @JsonKey(name: 'marital_status')
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
      @JsonKey(name: 'marital_status') final String? maritalStatus,
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
  @JsonKey(name: 'marital_status')
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
  @JsonKey(name: 'age_range')
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
      {@JsonKey(name: 'age_range') String? ageRange,
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
      {@JsonKey(name: 'age_range') String? ageRange,
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
      {@JsonKey(name: 'age_range') this.ageRange,
      this.demography,
      this.education,
      this.ethnicity,
      this.religion});

  factory _$PreferencesImpl.fromJson(Map<String, dynamic> json) =>
      _$$PreferencesImplFromJson(json);

  @override
  @JsonKey(name: 'age_range')
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
      {@JsonKey(name: 'age_range') final String? ageRange,
      final String? demography,
      final String? education,
      final String? ethnicity,
      final String? religion}) = _$PreferencesImpl;

  factory _Preferences.fromJson(Map<String, dynamic> json) =
      _$PreferencesImpl.fromJson;

  @override
  @JsonKey(name: 'age_range')
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

BlockedUser _$BlockedUserFromJson(Map<String, dynamic> json) {
  return _BlockedUser.fromJson(json);
}

/// @nodoc
mixin _$BlockedUser {
  String? get id => throw _privateConstructorUsedError;
  Metal? get metal => throw _privateConstructorUsedError;
  String? get name => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $BlockedUserCopyWith<BlockedUser> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockedUserCopyWith<$Res> {
  factory $BlockedUserCopyWith(
          BlockedUser value, $Res Function(BlockedUser) then) =
      _$BlockedUserCopyWithImpl<$Res, BlockedUser>;
  @useResult
  $Res call({String? id, Metal? metal, String? name});
}

/// @nodoc
class _$BlockedUserCopyWithImpl<$Res, $Val extends BlockedUser>
    implements $BlockedUserCopyWith<$Res> {
  _$BlockedUserCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? metal = freezed,
    Object? name = freezed,
  }) {
    return _then(_value.copyWith(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      metal: freezed == metal
          ? _value.metal
          : metal // ignore: cast_nullable_to_non_nullable
              as Metal?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BlockedUserImplCopyWith<$Res>
    implements $BlockedUserCopyWith<$Res> {
  factory _$$BlockedUserImplCopyWith(
          _$BlockedUserImpl value, $Res Function(_$BlockedUserImpl) then) =
      __$$BlockedUserImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String? id, Metal? metal, String? name});
}

/// @nodoc
class __$$BlockedUserImplCopyWithImpl<$Res>
    extends _$BlockedUserCopyWithImpl<$Res, _$BlockedUserImpl>
    implements _$$BlockedUserImplCopyWith<$Res> {
  __$$BlockedUserImplCopyWithImpl(
      _$BlockedUserImpl _value, $Res Function(_$BlockedUserImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = freezed,
    Object? metal = freezed,
    Object? name = freezed,
  }) {
    return _then(_$BlockedUserImpl(
      id: freezed == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String?,
      metal: freezed == metal
          ? _value.metal
          : metal // ignore: cast_nullable_to_non_nullable
              as Metal?,
      name: freezed == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$BlockedUserImpl implements _BlockedUser {
  _$BlockedUserImpl({this.id, this.metal, this.name});

  factory _$BlockedUserImpl.fromJson(Map<String, dynamic> json) =>
      _$$BlockedUserImplFromJson(json);

  @override
  final String? id;
  @override
  final Metal? metal;
  @override
  final String? name;

  @override
  String toString() {
    return 'BlockedUser(id: $id, metal: $metal, name: $name)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockedUserImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.metal, metal) || other.metal == metal) &&
            (identical(other.name, name) || other.name == name));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, metal, name);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockedUserImplCopyWith<_$BlockedUserImpl> get copyWith =>
      __$$BlockedUserImplCopyWithImpl<_$BlockedUserImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$BlockedUserImplToJson(
      this,
    );
  }
}

abstract class _BlockedUser implements BlockedUser {
  factory _BlockedUser(
      {final String? id,
      final Metal? metal,
      final String? name}) = _$BlockedUserImpl;

  factory _BlockedUser.fromJson(Map<String, dynamic> json) =
      _$BlockedUserImpl.fromJson;

  @override
  String? get id;
  @override
  Metal? get metal;
  @override
  String? get name;
  @override
  @JsonKey(ignore: true)
  _$$BlockedUserImplCopyWith<_$BlockedUserImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
