// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'submission.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Submission _$SubmissionFromJson(Map<String, dynamic> json) {
  return _Submission.fromJson(json);
}

/// @nodoc
mixin _$Submission {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'rep_id')
  String get repId => throw _privateConstructorUsedError;
  @JsonKey(
    name: 'request_type',
    fromJson: RequestType.fromJson,
    toJson: _requestTypeToJson,
  )
  RequestType get requestType => throw _privateConstructorUsedError;
  @JsonKey(name: 'tray_type')
  String? get trayType => throw _privateConstructorUsedError;
  String? get surgeon => throw _privateConstructorUsedError;
  String? get facility => throw _privateConstructorUsedError;
  @JsonKey(name: 'surgery_date')
  String? get surgeryDate => throw _privateConstructorUsedError;
  String? get details => throw _privateConstructorUsedError;
  @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
  Priority get priority => throw _privateConstructorUsedError;
  @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
  SubmissionStatus get status => throw _privateConstructorUsedError;
  @JsonKey(name: 'status_note')
  String? get statusNote => throw _privateConstructorUsedError;
  String get source => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  String get createdAt => throw _privateConstructorUsedError;
  @JsonKey(name: 'updated_at')
  String get updatedAt => throw _privateConstructorUsedError; // Joined field — only present when fetching with profile join
  @JsonKey(name: 'rep_name')
  String? get repName => throw _privateConstructorUsedError;

  /// Serializes this Submission to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SubmissionCopyWith<Submission> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SubmissionCopyWith<$Res> {
  factory $SubmissionCopyWith(
    Submission value,
    $Res Function(Submission) then,
  ) = _$SubmissionCopyWithImpl<$Res, Submission>;
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'rep_id') String repId,
    @JsonKey(
      name: 'request_type',
      fromJson: RequestType.fromJson,
      toJson: _requestTypeToJson,
    )
    RequestType requestType,
    @JsonKey(name: 'tray_type') String? trayType,
    String? surgeon,
    String? facility,
    @JsonKey(name: 'surgery_date') String? surgeryDate,
    String? details,
    @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
    Priority priority,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    SubmissionStatus status,
    @JsonKey(name: 'status_note') String? statusNote,
    String source,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String updatedAt,
    @JsonKey(name: 'rep_name') String? repName,
  });
}

/// @nodoc
class _$SubmissionCopyWithImpl<$Res, $Val extends Submission>
    implements $SubmissionCopyWith<$Res> {
  _$SubmissionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? repId = null,
    Object? requestType = null,
    Object? trayType = freezed,
    Object? surgeon = freezed,
    Object? facility = freezed,
    Object? surgeryDate = freezed,
    Object? details = freezed,
    Object? priority = null,
    Object? status = null,
    Object? statusNote = freezed,
    Object? source = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? repName = freezed,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            repId: null == repId
                ? _value.repId
                : repId // ignore: cast_nullable_to_non_nullable
                      as String,
            requestType: null == requestType
                ? _value.requestType
                : requestType // ignore: cast_nullable_to_non_nullable
                      as RequestType,
            trayType: freezed == trayType
                ? _value.trayType
                : trayType // ignore: cast_nullable_to_non_nullable
                      as String?,
            surgeon: freezed == surgeon
                ? _value.surgeon
                : surgeon // ignore: cast_nullable_to_non_nullable
                      as String?,
            facility: freezed == facility
                ? _value.facility
                : facility // ignore: cast_nullable_to_non_nullable
                      as String?,
            surgeryDate: freezed == surgeryDate
                ? _value.surgeryDate
                : surgeryDate // ignore: cast_nullable_to_non_nullable
                      as String?,
            details: freezed == details
                ? _value.details
                : details // ignore: cast_nullable_to_non_nullable
                      as String?,
            priority: null == priority
                ? _value.priority
                : priority // ignore: cast_nullable_to_non_nullable
                      as Priority,
            status: null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                      as SubmissionStatus,
            statusNote: freezed == statusNote
                ? _value.statusNote
                : statusNote // ignore: cast_nullable_to_non_nullable
                      as String?,
            source: null == source
                ? _value.source
                : source // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as String,
            updatedAt: null == updatedAt
                ? _value.updatedAt
                : updatedAt // ignore: cast_nullable_to_non_nullable
                      as String,
            repName: freezed == repName
                ? _value.repName
                : repName // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$SubmissionImplCopyWith<$Res>
    implements $SubmissionCopyWith<$Res> {
  factory _$$SubmissionImplCopyWith(
    _$SubmissionImpl value,
    $Res Function(_$SubmissionImpl) then,
  ) = __$$SubmissionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    @JsonKey(name: 'rep_id') String repId,
    @JsonKey(
      name: 'request_type',
      fromJson: RequestType.fromJson,
      toJson: _requestTypeToJson,
    )
    RequestType requestType,
    @JsonKey(name: 'tray_type') String? trayType,
    String? surgeon,
    String? facility,
    @JsonKey(name: 'surgery_date') String? surgeryDate,
    String? details,
    @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
    Priority priority,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    SubmissionStatus status,
    @JsonKey(name: 'status_note') String? statusNote,
    String source,
    @JsonKey(name: 'created_at') String createdAt,
    @JsonKey(name: 'updated_at') String updatedAt,
    @JsonKey(name: 'rep_name') String? repName,
  });
}

/// @nodoc
class __$$SubmissionImplCopyWithImpl<$Res>
    extends _$SubmissionCopyWithImpl<$Res, _$SubmissionImpl>
    implements _$$SubmissionImplCopyWith<$Res> {
  __$$SubmissionImplCopyWithImpl(
    _$SubmissionImpl _value,
    $Res Function(_$SubmissionImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? repId = null,
    Object? requestType = null,
    Object? trayType = freezed,
    Object? surgeon = freezed,
    Object? facility = freezed,
    Object? surgeryDate = freezed,
    Object? details = freezed,
    Object? priority = null,
    Object? status = null,
    Object? statusNote = freezed,
    Object? source = null,
    Object? createdAt = null,
    Object? updatedAt = null,
    Object? repName = freezed,
  }) {
    return _then(
      _$SubmissionImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        repId: null == repId
            ? _value.repId
            : repId // ignore: cast_nullable_to_non_nullable
                  as String,
        requestType: null == requestType
            ? _value.requestType
            : requestType // ignore: cast_nullable_to_non_nullable
                  as RequestType,
        trayType: freezed == trayType
            ? _value.trayType
            : trayType // ignore: cast_nullable_to_non_nullable
                  as String?,
        surgeon: freezed == surgeon
            ? _value.surgeon
            : surgeon // ignore: cast_nullable_to_non_nullable
                  as String?,
        facility: freezed == facility
            ? _value.facility
            : facility // ignore: cast_nullable_to_non_nullable
                  as String?,
        surgeryDate: freezed == surgeryDate
            ? _value.surgeryDate
            : surgeryDate // ignore: cast_nullable_to_non_nullable
                  as String?,
        details: freezed == details
            ? _value.details
            : details // ignore: cast_nullable_to_non_nullable
                  as String?,
        priority: null == priority
            ? _value.priority
            : priority // ignore: cast_nullable_to_non_nullable
                  as Priority,
        status: null == status
            ? _value.status
            : status // ignore: cast_nullable_to_non_nullable
                  as SubmissionStatus,
        statusNote: freezed == statusNote
            ? _value.statusNote
            : statusNote // ignore: cast_nullable_to_non_nullable
                  as String?,
        source: null == source
            ? _value.source
            : source // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as String,
        updatedAt: null == updatedAt
            ? _value.updatedAt
            : updatedAt // ignore: cast_nullable_to_non_nullable
                  as String,
        repName: freezed == repName
            ? _value.repName
            : repName // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$SubmissionImpl implements _Submission {
  const _$SubmissionImpl({
    required this.id,
    @JsonKey(name: 'rep_id') required this.repId,
    @JsonKey(
      name: 'request_type',
      fromJson: RequestType.fromJson,
      toJson: _requestTypeToJson,
    )
    required this.requestType,
    @JsonKey(name: 'tray_type') this.trayType,
    this.surgeon,
    this.facility,
    @JsonKey(name: 'surgery_date') this.surgeryDate,
    this.details,
    @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
    required this.priority,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    required this.status,
    @JsonKey(name: 'status_note') this.statusNote,
    required this.source,
    @JsonKey(name: 'created_at') required this.createdAt,
    @JsonKey(name: 'updated_at') required this.updatedAt,
    @JsonKey(name: 'rep_name') this.repName,
  });

  factory _$SubmissionImpl.fromJson(Map<String, dynamic> json) =>
      _$$SubmissionImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'rep_id')
  final String repId;
  @override
  @JsonKey(
    name: 'request_type',
    fromJson: RequestType.fromJson,
    toJson: _requestTypeToJson,
  )
  final RequestType requestType;
  @override
  @JsonKey(name: 'tray_type')
  final String? trayType;
  @override
  final String? surgeon;
  @override
  final String? facility;
  @override
  @JsonKey(name: 'surgery_date')
  final String? surgeryDate;
  @override
  final String? details;
  @override
  @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
  final Priority priority;
  @override
  @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
  final SubmissionStatus status;
  @override
  @JsonKey(name: 'status_note')
  final String? statusNote;
  @override
  final String source;
  @override
  @JsonKey(name: 'created_at')
  final String createdAt;
  @override
  @JsonKey(name: 'updated_at')
  final String updatedAt;
  // Joined field — only present when fetching with profile join
  @override
  @JsonKey(name: 'rep_name')
  final String? repName;

  @override
  String toString() {
    return 'Submission(id: $id, repId: $repId, requestType: $requestType, trayType: $trayType, surgeon: $surgeon, facility: $facility, surgeryDate: $surgeryDate, details: $details, priority: $priority, status: $status, statusNote: $statusNote, source: $source, createdAt: $createdAt, updatedAt: $updatedAt, repName: $repName)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SubmissionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.repId, repId) || other.repId == repId) &&
            (identical(other.requestType, requestType) ||
                other.requestType == requestType) &&
            (identical(other.trayType, trayType) ||
                other.trayType == trayType) &&
            (identical(other.surgeon, surgeon) || other.surgeon == surgeon) &&
            (identical(other.facility, facility) ||
                other.facility == facility) &&
            (identical(other.surgeryDate, surgeryDate) ||
                other.surgeryDate == surgeryDate) &&
            (identical(other.details, details) || other.details == details) &&
            (identical(other.priority, priority) ||
                other.priority == priority) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.statusNote, statusNote) ||
                other.statusNote == statusNote) &&
            (identical(other.source, source) || other.source == source) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt) &&
            (identical(other.repName, repName) || other.repName == repName));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    repId,
    requestType,
    trayType,
    surgeon,
    facility,
    surgeryDate,
    details,
    priority,
    status,
    statusNote,
    source,
    createdAt,
    updatedAt,
    repName,
  );

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      __$$SubmissionImplCopyWithImpl<_$SubmissionImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$SubmissionImplToJson(this);
  }
}

abstract class _Submission implements Submission {
  const factory _Submission({
    required final String id,
    @JsonKey(name: 'rep_id') required final String repId,
    @JsonKey(
      name: 'request_type',
      fromJson: RequestType.fromJson,
      toJson: _requestTypeToJson,
    )
    required final RequestType requestType,
    @JsonKey(name: 'tray_type') final String? trayType,
    final String? surgeon,
    final String? facility,
    @JsonKey(name: 'surgery_date') final String? surgeryDate,
    final String? details,
    @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
    required final Priority priority,
    @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
    required final SubmissionStatus status,
    @JsonKey(name: 'status_note') final String? statusNote,
    required final String source,
    @JsonKey(name: 'created_at') required final String createdAt,
    @JsonKey(name: 'updated_at') required final String updatedAt,
    @JsonKey(name: 'rep_name') final String? repName,
  }) = _$SubmissionImpl;

  factory _Submission.fromJson(Map<String, dynamic> json) =
      _$SubmissionImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'rep_id')
  String get repId;
  @override
  @JsonKey(
    name: 'request_type',
    fromJson: RequestType.fromJson,
    toJson: _requestTypeToJson,
  )
  RequestType get requestType;
  @override
  @JsonKey(name: 'tray_type')
  String? get trayType;
  @override
  String? get surgeon;
  @override
  String? get facility;
  @override
  @JsonKey(name: 'surgery_date')
  String? get surgeryDate;
  @override
  String? get details;
  @override
  @JsonKey(fromJson: Priority.fromJson, toJson: _priorityToJson)
  Priority get priority;
  @override
  @JsonKey(fromJson: SubmissionStatus.fromJson, toJson: _statusToJson)
  SubmissionStatus get status;
  @override
  @JsonKey(name: 'status_note')
  String? get statusNote;
  @override
  String get source;
  @override
  @JsonKey(name: 'created_at')
  String get createdAt;
  @override
  @JsonKey(name: 'updated_at')
  String get updatedAt; // Joined field — only present when fetching with profile join
  @override
  @JsonKey(name: 'rep_name')
  String? get repName;

  /// Create a copy of Submission
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SubmissionImplCopyWith<_$SubmissionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
