// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'thought.model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ThoughtModel _$ThoughtModelFromJson(Map<String, dynamic> json) {
  return _ThoughtModel.fromJson(json);
}

/// @nodoc
mixin _$ThoughtModel {
  String get id =>
      throw _privateConstructorUsedError; // Unique ID for the thought
  String get userId =>
      throw _privateConstructorUsedError; // The user who posted the thought
  String get content =>
      throw _privateConstructorUsedError; // The text content of the thought
  String get createdAt =>
      throw _privateConstructorUsedError; // Timestamp of when the thought was created
  bool get connectionOnly =>
      throw _privateConstructorUsedError; // Whether the thought is visible only to connections
  List<ReactionModel> get reactions => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ThoughtModelCopyWith<ThoughtModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ThoughtModelCopyWith<$Res> {
  factory $ThoughtModelCopyWith(
          ThoughtModel value, $Res Function(ThoughtModel) then) =
      _$ThoughtModelCopyWithImpl<$Res, ThoughtModel>;
  @useResult
  $Res call(
      {String id,
      String userId,
      String content,
      String createdAt,
      bool connectionOnly,
      List<ReactionModel> reactions});
}

/// @nodoc
class _$ThoughtModelCopyWithImpl<$Res, $Val extends ThoughtModel>
    implements $ThoughtModelCopyWith<$Res> {
  _$ThoughtModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? connectionOnly = null,
    Object? reactions = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      connectionOnly: null == connectionOnly
          ? _value.connectionOnly
          : connectionOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      reactions: null == reactions
          ? _value.reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<ReactionModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ThoughtModelImplCopyWith<$Res>
    implements $ThoughtModelCopyWith<$Res> {
  factory _$$ThoughtModelImplCopyWith(
          _$ThoughtModelImpl value, $Res Function(_$ThoughtModelImpl) then) =
      __$$ThoughtModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String userId,
      String content,
      String createdAt,
      bool connectionOnly,
      List<ReactionModel> reactions});
}

/// @nodoc
class __$$ThoughtModelImplCopyWithImpl<$Res>
    extends _$ThoughtModelCopyWithImpl<$Res, _$ThoughtModelImpl>
    implements _$$ThoughtModelImplCopyWith<$Res> {
  __$$ThoughtModelImplCopyWithImpl(
      _$ThoughtModelImpl _value, $Res Function(_$ThoughtModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userId = null,
    Object? content = null,
    Object? createdAt = null,
    Object? connectionOnly = null,
    Object? reactions = null,
  }) {
    return _then(_$ThoughtModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      content: null == content
          ? _value.content
          : content // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as String,
      connectionOnly: null == connectionOnly
          ? _value.connectionOnly
          : connectionOnly // ignore: cast_nullable_to_non_nullable
              as bool,
      reactions: null == reactions
          ? _value._reactions
          : reactions // ignore: cast_nullable_to_non_nullable
              as List<ReactionModel>,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ThoughtModelImpl implements _ThoughtModel {
  _$ThoughtModelImpl(
      {required this.id,
      required this.userId,
      required this.content,
      required this.createdAt,
      this.connectionOnly = false,
      final List<ReactionModel> reactions = const []})
      : _reactions = reactions;

  factory _$ThoughtModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ThoughtModelImplFromJson(json);

  @override
  final String id;
// Unique ID for the thought
  @override
  final String userId;
// The user who posted the thought
  @override
  final String content;
// The text content of the thought
  @override
  final String createdAt;
// Timestamp of when the thought was created
  @override
  @JsonKey()
  final bool connectionOnly;
// Whether the thought is visible only to connections
  final List<ReactionModel> _reactions;
// Whether the thought is visible only to connections
  @override
  @JsonKey()
  List<ReactionModel> get reactions {
    if (_reactions is EqualUnmodifiableListView) return _reactions;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_reactions);
  }

  @override
  String toString() {
    return 'ThoughtModel(id: $id, userId: $userId, content: $content, createdAt: $createdAt, connectionOnly: $connectionOnly, reactions: $reactions)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ThoughtModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.connectionOnly, connectionOnly) ||
                other.connectionOnly == connectionOnly) &&
            const DeepCollectionEquality()
                .equals(other._reactions, _reactions));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, userId, content, createdAt,
      connectionOnly, const DeepCollectionEquality().hash(_reactions));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ThoughtModelImplCopyWith<_$ThoughtModelImpl> get copyWith =>
      __$$ThoughtModelImplCopyWithImpl<_$ThoughtModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ThoughtModelImplToJson(
      this,
    );
  }
}

abstract class _ThoughtModel implements ThoughtModel {
  factory _ThoughtModel(
      {required final String id,
      required final String userId,
      required final String content,
      required final String createdAt,
      final bool connectionOnly,
      final List<ReactionModel> reactions}) = _$ThoughtModelImpl;

  factory _ThoughtModel.fromJson(Map<String, dynamic> json) =
      _$ThoughtModelImpl.fromJson;

  @override
  String get id;
  @override // Unique ID for the thought
  String get userId;
  @override // The user who posted the thought
  String get content;
  @override // The text content of the thought
  String get createdAt;
  @override // Timestamp of when the thought was created
  bool get connectionOnly;
  @override // Whether the thought is visible only to connections
  List<ReactionModel> get reactions;
  @override
  @JsonKey(ignore: true)
  _$$ThoughtModelImplCopyWith<_$ThoughtModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ReactionModel _$ReactionModelFromJson(Map<String, dynamic> json) {
  return _ReactionModel.fromJson(json);
}

/// @nodoc
mixin _$ReactionModel {
  String get userId =>
      throw _privateConstructorUsedError; // ID of the user reacting
  String get emoji => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $ReactionModelCopyWith<ReactionModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ReactionModelCopyWith<$Res> {
  factory $ReactionModelCopyWith(
          ReactionModel value, $Res Function(ReactionModel) then) =
      _$ReactionModelCopyWithImpl<$Res, ReactionModel>;
  @useResult
  $Res call({String userId, String emoji});
}

/// @nodoc
class _$ReactionModelCopyWithImpl<$Res, $Val extends ReactionModel>
    implements $ReactionModelCopyWith<$Res> {
  _$ReactionModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? emoji = null,
  }) {
    return _then(_value.copyWith(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ReactionModelImplCopyWith<$Res>
    implements $ReactionModelCopyWith<$Res> {
  factory _$$ReactionModelImplCopyWith(
          _$ReactionModelImpl value, $Res Function(_$ReactionModelImpl) then) =
      __$$ReactionModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String userId, String emoji});
}

/// @nodoc
class __$$ReactionModelImplCopyWithImpl<$Res>
    extends _$ReactionModelCopyWithImpl<$Res, _$ReactionModelImpl>
    implements _$$ReactionModelImplCopyWith<$Res> {
  __$$ReactionModelImplCopyWithImpl(
      _$ReactionModelImpl _value, $Res Function(_$ReactionModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? userId = null,
    Object? emoji = null,
  }) {
    return _then(_$ReactionModelImpl(
      userId: null == userId
          ? _value.userId
          : userId // ignore: cast_nullable_to_non_nullable
              as String,
      emoji: null == emoji
          ? _value.emoji
          : emoji // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ReactionModelImpl implements _ReactionModel {
  _$ReactionModelImpl({required this.userId, required this.emoji});

  factory _$ReactionModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ReactionModelImplFromJson(json);

  @override
  final String userId;
// ID of the user reacting
  @override
  final String emoji;

  @override
  String toString() {
    return 'ReactionModel(userId: $userId, emoji: $emoji)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ReactionModelImpl &&
            (identical(other.userId, userId) || other.userId == userId) &&
            (identical(other.emoji, emoji) || other.emoji == emoji));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, userId, emoji);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$ReactionModelImplCopyWith<_$ReactionModelImpl> get copyWith =>
      __$$ReactionModelImplCopyWithImpl<_$ReactionModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ReactionModelImplToJson(
      this,
    );
  }
}

abstract class _ReactionModel implements ReactionModel {
  factory _ReactionModel(
      {required final String userId,
      required final String emoji}) = _$ReactionModelImpl;

  factory _ReactionModel.fromJson(Map<String, dynamic> json) =
      _$ReactionModelImpl.fromJson;

  @override
  String get userId;
  @override // ID of the user reacting
  String get emoji;
  @override
  @JsonKey(ignore: true)
  _$$ReactionModelImplCopyWith<_$ReactionModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
