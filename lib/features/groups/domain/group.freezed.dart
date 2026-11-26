// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'group.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Group {

 String get id; String get name;/// Join code, like `LIQ-7K4P` (see `GroupCode`).
 String get code;/// Main admin: the creator, or whoever inherited the group when the
/// previous one left. Always the first of [adminUids]; nobody can
/// remove them or take away their role.
 String get ownerUid;/// Active members who administer the group, in the order they became
/// admins (the owner first).
 List<String> get adminUids;/// New members wait for the admin's approval.
 bool get requiresApproval;/// A password is asked for when joining.
 bool get hasPassword;/// Active members.
 List<String> get memberUids;/// Members waiting for approval.
 List<String> get pendingUids;/// Set by the server; `null` while a local write is pending.
 DateTime? get createdAt;/// Soft delete: nothing is physically deleted.
 DateTime? get deletedAt;
/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GroupCopyWith<Group> get copyWith => _$GroupCopyWithImpl<Group>(this as Group, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Group;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Group&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.code, _this.code) || other.code == _this.code)&&(identical(other.ownerUid, _this.ownerUid) || other.ownerUid == _this.ownerUid)&&const DeepCollectionEquality().equals(other.adminUids, _this.adminUids)&&(identical(other.requiresApproval, _this.requiresApproval) || other.requiresApproval == _this.requiresApproval)&&(identical(other.hasPassword, _this.hasPassword) || other.hasPassword == _this.hasPassword)&&const DeepCollectionEquality().equals(other.memberUids, _this.memberUids)&&const DeepCollectionEquality().equals(other.pendingUids, _this.pendingUids)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as Group;
  return Object.hash(runtimeType,_this.id,_this.name,_this.code,_this.ownerUid,const DeepCollectionEquality().hash(_this.adminUids),_this.requiresApproval,_this.hasPassword,const DeepCollectionEquality().hash(_this.memberUids),const DeepCollectionEquality().hash(_this.pendingUids),_this.createdAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as Group;
  return 'Group(id: ${_this.id}, name: ${_this.name}, code: ${_this.code}, ownerUid: ${_this.ownerUid}, adminUids: ${_this.adminUids}, requiresApproval: ${_this.requiresApproval}, hasPassword: ${_this.hasPassword}, memberUids: ${_this.memberUids}, pendingUids: ${_this.pendingUids}, createdAt: ${_this.createdAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $GroupCopyWith<$Res>  {
  factory $GroupCopyWith(Group value, $Res Function(Group) _then) = _$GroupCopyWithImpl;
@useResult
$Res call({
 String id, String name, String code, String ownerUid, List<String> adminUids, bool requiresApproval, bool hasPassword, List<String> memberUids, List<String> pendingUids, DateTime? createdAt, DateTime? deletedAt
});




}
/// @nodoc
class _$GroupCopyWithImpl<$Res>
    implements $GroupCopyWith<$Res> {
  _$GroupCopyWithImpl(this._self, this._then);

  final Group _self;
  final $Res Function(Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? code = null,Object? ownerUid = null,Object? adminUids = null,Object? requiresApproval = null,Object? hasPassword = null,Object? memberUids = null,Object? pendingUids = null,Object? createdAt = freezed,Object? deletedAt = freezed,}) {
  return _then(Group(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,adminUids: null == adminUids ? _self.adminUids : adminUids // ignore: cast_nullable_to_non_nullable
as List<String>,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,memberUids: null == memberUids ? _self.memberUids : memberUids // ignore: cast_nullable_to_non_nullable
as List<String>,pendingUids: null == pendingUids ? _self.pendingUids : pendingUids // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Group].
extension GroupPatterns on Group {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Group value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Group value)  $default,){
final _that = this;
switch (_that) {
case _Group():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Group value)?  $default,){
final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String code,  String ownerUid,  List<String> adminUids,  bool requiresApproval,  bool hasPassword,  List<String> memberUids,  List<String> pendingUids,  DateTime? createdAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.ownerUid,_that.adminUids,_that.requiresApproval,_that.hasPassword,_that.memberUids,_that.pendingUids,_that.createdAt,_that.deletedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String code,  String ownerUid,  List<String> adminUids,  bool requiresApproval,  bool hasPassword,  List<String> memberUids,  List<String> pendingUids,  DateTime? createdAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _Group():
return $default(_that.id,_that.name,_that.code,_that.ownerUid,_that.adminUids,_that.requiresApproval,_that.hasPassword,_that.memberUids,_that.pendingUids,_that.createdAt,_that.deletedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String code,  String ownerUid,  List<String> adminUids,  bool requiresApproval,  bool hasPassword,  List<String> memberUids,  List<String> pendingUids,  DateTime? createdAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _Group() when $default != null:
return $default(_that.id,_that.name,_that.code,_that.ownerUid,_that.adminUids,_that.requiresApproval,_that.hasPassword,_that.memberUids,_that.pendingUids,_that.createdAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _Group extends Group {
  const _Group({required this.id, required this.name, required this.code, required this.ownerUid,  List<String> adminUids = const <String>[], this.requiresApproval = false, this.hasPassword = false,  List<String> memberUids = const <String>[],  List<String> pendingUids = const <String>[], this.createdAt, this.deletedAt}): _adminUids = adminUids,_memberUids = memberUids,_pendingUids = pendingUids,super._();
  

@override final  String id;
@override final  String name;
/// Join code, like `LIQ-7K4P` (see `GroupCode`).
@override final  String code;
/// Main admin: the creator, or whoever inherited the group when the
/// previous one left. Always the first of [adminUids]; nobody can
/// remove them or take away their role.
@override final  String ownerUid;
/// Active members who administer the group, in the order they became
/// admins (the owner first).
 final  List<String> _adminUids;
/// Active members who administer the group, in the order they became
/// admins (the owner first).
@override@JsonKey() List<String> get adminUids {
  if (_adminUids is EqualUnmodifiableListView) return _adminUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_adminUids);
}

/// New members wait for the admin's approval.
@override@JsonKey() final  bool requiresApproval;
/// A password is asked for when joining.
@override@JsonKey() final  bool hasPassword;
/// Active members.
 final  List<String> _memberUids;
/// Active members.
@override@JsonKey() List<String> get memberUids {
  if (_memberUids is EqualUnmodifiableListView) return _memberUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberUids);
}

/// Members waiting for approval.
 final  List<String> _pendingUids;
/// Members waiting for approval.
@override@JsonKey() List<String> get pendingUids {
  if (_pendingUids is EqualUnmodifiableListView) return _pendingUids;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_pendingUids);
}

/// Set by the server; `null` while a local write is pending.
@override final  DateTime? createdAt;
/// Soft delete: nothing is physically deleted.
@override final  DateTime? deletedAt;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GroupCopyWith<_Group> get copyWith => __$GroupCopyWithImpl<_Group>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Group&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.code, code) || other.code == code)&&(identical(other.ownerUid, ownerUid) || other.ownerUid == ownerUid)&&const DeepCollectionEquality().equals(other.adminUids, _adminUids)&&(identical(other.requiresApproval, requiresApproval) || other.requiresApproval == requiresApproval)&&(identical(other.hasPassword, hasPassword) || other.hasPassword == hasPassword)&&const DeepCollectionEquality().equals(other.memberUids, _memberUids)&&const DeepCollectionEquality().equals(other.pendingUids, _pendingUids)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,code,ownerUid,const DeepCollectionEquality().hash(_adminUids),requiresApproval,hasPassword,const DeepCollectionEquality().hash(_memberUids),const DeepCollectionEquality().hash(_pendingUids),createdAt,deletedAt);
}

@override
String toString() {
    return 'Group(id: $id, name: $name, code: $code, ownerUid: $ownerUid, adminUids: $adminUids, requiresApproval: $requiresApproval, hasPassword: $hasPassword, memberUids: $memberUids, pendingUids: $pendingUids, createdAt: $createdAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$GroupCopyWith<$Res> implements $GroupCopyWith<$Res> {
  factory _$GroupCopyWith(_Group value, $Res Function(_Group) _then) = __$GroupCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String code, String ownerUid, List<String> adminUids, bool requiresApproval, bool hasPassword, List<String> memberUids, List<String> pendingUids, DateTime? createdAt, DateTime? deletedAt
});




}
/// @nodoc
class __$GroupCopyWithImpl<$Res>
    implements _$GroupCopyWith<$Res> {
  __$GroupCopyWithImpl(this._self, this._then);

  final _Group _self;
  final $Res Function(_Group) _then;

/// Create a copy of Group
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? code = null,Object? ownerUid = null,Object? adminUids = null,Object? requiresApproval = null,Object? hasPassword = null,Object? memberUids = null,Object? pendingUids = null,Object? createdAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_Group(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,code: null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,ownerUid: null == ownerUid ? _self.ownerUid : ownerUid // ignore: cast_nullable_to_non_nullable
as String,adminUids: null == adminUids ? _self._adminUids : adminUids // ignore: cast_nullable_to_non_nullable
as List<String>,requiresApproval: null == requiresApproval ? _self.requiresApproval : requiresApproval // ignore: cast_nullable_to_non_nullable
as bool,hasPassword: null == hasPassword ? _self.hasPassword : hasPassword // ignore: cast_nullable_to_non_nullable
as bool,memberUids: null == memberUids ? _self._memberUids : memberUids // ignore: cast_nullable_to_non_nullable
as List<String>,pendingUids: null == pendingUids ? _self._pendingUids : pendingUids // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
