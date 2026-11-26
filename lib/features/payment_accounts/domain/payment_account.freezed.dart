// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'payment_account.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentAccount {

 String get id;/// Name chosen by the user, like "Nequi personal".
 String get name; PaymentAccountType get type;/// Only for [PaymentAccountType.breb].
 BrebKeyType? get keyType;/// Without format: only digits for phones and documents. Empty for
/// [PaymentAccountType.cash].
 String get reference; DateTime? get createdAt; DateTime? get updatedAt; DateTime? get deletedAt;
/// Create a copy of PaymentAccount
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentAccountCopyWith<PaymentAccount> get copyWith => _$PaymentAccountCopyWithImpl<PaymentAccount>(this as PaymentAccount, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentAccount;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentAccount&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.keyType, _this.keyType) || other.keyType == _this.keyType)&&(identical(other.reference, _this.reference) || other.reference == _this.reference)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.updatedAt, _this.updatedAt) || other.updatedAt == _this.updatedAt)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt));
}


@override
int get hashCode {
  final _this = this as PaymentAccount;
  return Object.hash(runtimeType,_this.id,_this.name,_this.type,_this.keyType,_this.reference,_this.createdAt,_this.updatedAt,_this.deletedAt);
}

@override
String toString() {
  final _this = this as PaymentAccount;
  return 'PaymentAccount(id: ${_this.id}, name: ${_this.name}, type: ${_this.type}, keyType: ${_this.keyType}, reference: ${_this.reference}, createdAt: ${_this.createdAt}, updatedAt: ${_this.updatedAt}, deletedAt: ${_this.deletedAt})';
}


}

/// @nodoc
abstract mixin class $PaymentAccountCopyWith<$Res>  {
  factory $PaymentAccountCopyWith(PaymentAccount value, $Res Function(PaymentAccount) _then) = _$PaymentAccountCopyWithImpl;
@useResult
$Res call({
 String id, String name, PaymentAccountType type, BrebKeyType? keyType, String reference, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class _$PaymentAccountCopyWithImpl<$Res>
    implements $PaymentAccountCopyWith<$Res> {
  _$PaymentAccountCopyWithImpl(this._self, this._then);

  final PaymentAccount _self;
  final $Res Function(PaymentAccount) _then;

/// Create a copy of PaymentAccount
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? keyType = freezed,Object? reference = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(PaymentAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentAccountType,keyType: freezed == keyType ? _self.keyType : keyType // ignore: cast_nullable_to_non_nullable
as BrebKeyType?,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentAccount].
extension PaymentAccountPatterns on PaymentAccount {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentAccount value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentAccount() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentAccount value)  $default,){
final _that = this;
switch (_that) {
case _PaymentAccount():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentAccount value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentAccount() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  PaymentAccountType type,  BrebKeyType? keyType,  String reference,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentAccount() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.keyType,_that.reference,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  PaymentAccountType type,  BrebKeyType? keyType,  String reference,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)  $default,) {final _that = this;
switch (_that) {
case _PaymentAccount():
return $default(_that.id,_that.name,_that.type,_that.keyType,_that.reference,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  PaymentAccountType type,  BrebKeyType? keyType,  String reference,  DateTime? createdAt,  DateTime? updatedAt,  DateTime? deletedAt)?  $default,) {final _that = this;
switch (_that) {
case _PaymentAccount() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.keyType,_that.reference,_that.createdAt,_that.updatedAt,_that.deletedAt);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentAccount extends PaymentAccount {
  const _PaymentAccount({required this.id, required this.name, required this.type, this.keyType, required this.reference, this.createdAt, this.updatedAt, this.deletedAt}): super._();
  

@override final  String id;
/// Name chosen by the user, like "Nequi personal".
@override final  String name;
@override final  PaymentAccountType type;
/// Only for [PaymentAccountType.breb].
@override final  BrebKeyType? keyType;
/// Without format: only digits for phones and documents. Empty for
/// [PaymentAccountType.cash].
@override final  String reference;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  DateTime? deletedAt;

/// Create a copy of PaymentAccount
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentAccountCopyWith<_PaymentAccount> get copyWith => __$PaymentAccountCopyWithImpl<_PaymentAccount>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentAccount&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&(identical(other.keyType, keyType) || other.keyType == keyType)&&(identical(other.reference, reference) || other.reference == reference)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,name,type,keyType,reference,createdAt,updatedAt,deletedAt);
}

@override
String toString() {
    return 'PaymentAccount(id: $id, name: $name, type: $type, keyType: $keyType, reference: $reference, createdAt: $createdAt, updatedAt: $updatedAt, deletedAt: $deletedAt)';
}


}

/// @nodoc
abstract mixin class _$PaymentAccountCopyWith<$Res> implements $PaymentAccountCopyWith<$Res> {
  factory _$PaymentAccountCopyWith(_PaymentAccount value, $Res Function(_PaymentAccount) _then) = __$PaymentAccountCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, PaymentAccountType type, BrebKeyType? keyType, String reference, DateTime? createdAt, DateTime? updatedAt, DateTime? deletedAt
});




}
/// @nodoc
class __$PaymentAccountCopyWithImpl<$Res>
    implements _$PaymentAccountCopyWith<$Res> {
  __$PaymentAccountCopyWithImpl(this._self, this._then);

  final _PaymentAccount _self;
  final $Res Function(_PaymentAccount) _then;

/// Create a copy of PaymentAccount
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? keyType = freezed,Object? reference = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? deletedAt = freezed,}) {
  return _then(_PaymentAccount(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentAccountType,keyType: freezed == keyType ? _self.keyType : keyType // ignore: cast_nullable_to_non_nullable
as BrebKeyType?,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
