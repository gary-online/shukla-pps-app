// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'status_history_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

StatusHistoryEntry _$StatusHistoryEntryFromJson(Map<String, dynamic> json) {
  return _StatusHistoryEntry.fromJson(json);
}

/// @nodoc
mixin _$StatusHistoryEntry {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'submission_id')
  String get submissionId => throw _privateConstructorUsedError;
  @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
  SubmissionStatus get status => throw _privateConstructorUsedError;
  String? get note => throw _privateConstructorUsedError;
  @JsonKey(name: 'changed_by')
  String get changedBy => throw _privateConstructorUsedError;
  @JsonKey(name: 'changed_by_name')
  String? get changedByName => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;

  /// Serializes this StatusHistoryEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $StatusHistoryEntryCopyWith<StatusHistoryEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $StatusHistoryEntryCopyWith<$Res> {
  factory $StatusHistoryEntryCopyWith(
    StatusHistoryEntry value,
    $Res Function(StatusHistoryEntry) then,
  ) = _$StatusHistoryEntryCopyWithImpl<$Res, StatusHistoryEntry>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'submission_id') String submissionId,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    SubmissionStatus status,
    String? note,
    @JsonKey(name: 'changed_by') String changedBy,
    @JsonKey(name: 'changed_by_name') String? changedByName,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class _$StatusHistoryEntryCopyWithImpl<$Res, $Val extends StatusHistoryEntry>
    implements $StatusHistoryEntryCopyWith<$Res> {
  _$StatusHistoryEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? status = null,
    Object? note = freezed,
    Object? changedBy = null,
    Object? changedByName = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            submissionId: null == submissionId
                ? _value.submissionId
                : submissionId // ignore: cast_nullable_to_non_nullable
                      as String,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubmissionStatus,
            note: freezed == note
                ? _value.note
                : note // ignore: cast_nullable_to_non_nullable
                      as String?,
            changedBy: null == changedBy
                ? _value.changedBy
                : changedBy // ignore: cast_nullable_to_non_nullable
                      as String,
            changedByName: freezed == changedByName
                ? _value.changedByName
                : changedByName // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$StatusHistoryEntryImplCopyWith<$Res>
    implements $StatusHistoryEntryCopyWith<$Res> {
  factory _$$StatusHistoryEntryImplCopyWith(
    _$StatusHistoryEntryImpl value,
    $Res Function(_$StatusHistoryEntryImpl) then,
  ) = __$$StatusHistoryEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'submission_id') String submissionId,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    SubmissionStatus status,
    String? note,
    @JsonKey(name: 'changed_by') String changedBy,
    @JsonKey(name: 'changed_by_name') String? changedByName,
    @JsonKey(name: 'created_at') String createdAt,
  });
}

/// @nodoc
class __$$StatusHistoryEntryImplCopyWithImpl<$Res>
    extends _$StatusHistoryEntryCopyWithImpl<$Res, _$StatusHistoryEntryImpl>
    implements _$$StatusHistoryEntryImplCopyWith<$Res> {
  __$$StatusHistoryEntryImplCopyWithImpl(
    _$StatusHistoryEntryImpl _value,
    $Res Function(_$StatusHistoryEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? submissionId = null,
    Object? status = null,
    Object? note = freezed,
    Object? changedBy = null,
    Object? changedByName = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$StatusHistoryEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        submissionId: null == submissionId
            ? _value.submissionId
            : submissionId // ignore: cast_nullable_to_non_nullable
                  as String,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubmissionStatus,
        note: freezed == note
            ? _value.note
            : note // ignore: cast_nullable_to_non_nullable
                  as String?,
        changedBy: null == changedBy
            ? _value.changedBy
            : changedBy // ignore: cast_nullable_to_non_nullable
                  as String,
        changedByName: freezed == changedByName
            ? _value.changedByName
            : changedByName // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$StatusHistoryEntryImpl implements _StatusHistoryEntry {
  const _$StatusHistoryEntryImpl({
    required this.id,
    @JsonKey(name: 'submission_id') required this.submissionId,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    required this.status,
    this.note,
    @JsonKey(name: 'changed_by') required this.changedBy,
    @JsonKey(name: 'changed_by_name') this.changedByName,
    @JsonKey(name: 'created_at') required this.createdAt,
  });

  factory _$StatusHistoryEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$StatusHistoryEntryImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'submission_id')
  final String submissionId;
  @override
  @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
  final SubmissionStatus status;
  @override
  final String? note;
  @override
  @JsonKey(name: 'changed_by')
  final String changedBy;
  @override
  @JsonKey(name: 'changed_by_name')
  final String? changedByName;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;

  @override
  String toString() {
    return 'StatusHistoryEntry(id: $id, submissionId: $submissionId, status: $status, note: $note, changedBy: $changedBy, changedByName: $changedByName, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$StatusHistoryEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.submissionId, submissionId) ||
                other.submissionId == submissionId) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.note, note) || other.note == note) &&
            (identical(other.changedBy, changedBy) ||
                other.changedBy == changedBy) &&
            (identical(other.changedByName, changedByName) ||
                other.changedByName == changedByName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    submissionId,
    status,
    note,
    changedBy,
    changedByName,
    createdAt,
  );

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$StatusHistoryEntryImplCopyWith<_$StatusHistoryEntryImpl> get copyWith =>
      __$$StatusHistoryEntryImplCopyWithImpl<_$StatusHistoryEntryImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$StatusHistoryEntryImplToJson(this);
  }
}

abstract class _StatusHistoryEntry implements StatusHistoryEntry {
  const factory _StatusHistoryEntry({
    required final String id,
    @JsonKey(name: 'submission_id') required final String submissionId,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    required final SubmissionStatus status,
    final String? note,
    @JsonKey(name: 'changed_by') required final String changedBy,
    @JsonKey(name: 'changed_by_name') final String? changedByName,
    @JsonKey(name: 'created_at') required final String createdAt,
  }) = _$StatusHistoryEntryImpl;

  factory _StatusHistoryEntry.fromJson(Map<String, dynamic> json) =
      _$StatusHistoryEntryImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'submission_id')
  String get submissionId;
  @override
  @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
  SubmissionStatus get status;
  @override
  String? get note;
  @override
  @JsonKey(name: 'changed_by')
  String get changedBy;
  @override
  @JsonKey(name: 'changed_by_name')
  String? get changedByName;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;

  /// Create a copy of StatusHistoryEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$StatusHistoryEntryImplCopyWith<_$StatusHistoryEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
