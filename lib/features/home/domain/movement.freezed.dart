// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Movement {

 String get id; MovementType get type;/// Whole pesos (COP), always positive; the sign comes from [type].
 int get amount;/// "@juliana te pagó".
 String get title;/// Place or event, like "Crepes & Waffles".
 String get place; DateTime get createdAt;/// People a payment was split among (`null` or 1: not split).
 int? get participants;
/// Create a copy of Movement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementCopyWith<Movement> get copyWith => _$MovementCopyWithImpl<Movement>(this as Movement, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as Movement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Movement&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.title, _this.title) || other.title == _this.title)&&(identical(other.place, _this.place) || other.place == _this.place)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.participants, _this.participants) || other.participants == _this.participants));
}


@override
int get hashCode {
  final _this = this as Movement;
  return Object.hash(runtimeType,_this.id,_this.type,_this.amount,_this.title,_this.place,_this.createdAt,_this.participants);
}

@override
String toString() {
  final _this = this as Movement;
  return 'Movement(id: ${_this.id}, type: ${_this.type}, amount: ${_this.amount}, title: ${_this.title}, place: ${_this.place}, createdAt: ${_this.createdAt}, participants: ${_this.participants})';
}


}

/// @nodoc
abstract mixin class $MovementCopyWith<$Res>  {
  factory $MovementCopyWith(Movement value, $Res Function(Movement) _then) = _$MovementCopyWithImpl;
@useResult
$Res call({
 String id, MovementType type, int amount, String title, String place, DateTime createdAt, int? participants
});




}
/// @nodoc
class _$MovementCopyWithImpl<$Res>
    implements $MovementCopyWith<$Res> {
  _$MovementCopyWithImpl(this._self, this._then);

  final Movement _self;
  final $Res Function(Movement) _then;

/// Create a copy of Movement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? title = null,Object? place = null,Object? createdAt = null,Object? participants = freezed,}) {
  return _then(Movement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MovementType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,participants: freezed == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [Movement].
extension MovementPatterns on Movement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Movement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Movement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Movement value)  $default,){
final _that = this;
switch (_that) {
case _Movement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Movement value)?  $default,){
final _that = this;
switch (_that) {
case _Movement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  MovementType type,  int amount,  String title,  String place,  DateTime createdAt,  int? participants)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Movement() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.title,_that.place,_that.createdAt,_that.participants);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  MovementType type,  int amount,  String title,  String place,  DateTime createdAt,  int? participants)  $default,) {final _that = this;
switch (_that) {
case _Movement():
return $default(_that.id,_that.type,_that.amount,_that.title,_that.place,_that.createdAt,_that.participants);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  MovementType type,  int amount,  String title,  String place,  DateTime createdAt,  int? participants)?  $default,) {final _that = this;
switch (_that) {
case _Movement() when $default != null:
return $default(_that.id,_that.type,_that.amount,_that.title,_that.place,_that.createdAt,_that.participants);case _:
  return null;

}
}

}

/// @nodoc


class _Movement implements Movement {
  const _Movement({required this.id, required this.type, required this.amount, required this.title, required this.place, required this.createdAt, this.participants});
  

@override final  String id;
@override final  MovementType type;
/// Whole pesos (COP), always positive; the sign comes from [type].
@override final  int amount;
/// "@juliana te pagó".
@override final  String title;
/// Place or event, like "Crepes & Waffles".
@override final  String place;
@override final  DateTime createdAt;
/// People a payment was split among (`null` or 1: not split).
@override final  int? participants;

/// Create a copy of Movement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementCopyWith<_Movement> get copyWith => __$MovementCopyWithImpl<_Movement>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _Movement&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.title, title) || other.title == title)&&(identical(other.place, place) || other.place == place)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.participants, participants) || other.participants == participants));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,type,amount,title,place,createdAt,participants);
}

@override
String toString() {
    return 'Movement(id: $id, type: $type, amount: $amount, title: $title, place: $place, createdAt: $createdAt, participants: $participants)';
}


}

/// @nodoc
abstract mixin class _$MovementCopyWith<$Res> implements $MovementCopyWith<$Res> {
  factory _$MovementCopyWith(_Movement value, $Res Function(_Movement) _then) = __$MovementCopyWithImpl;
@override @useResult
$Res call({
 String id, MovementType type, int amount, String title, String place, DateTime createdAt, int? participants
});




}
/// @nodoc
class __$MovementCopyWithImpl<$Res>
    implements _$MovementCopyWith<$Res> {
  __$MovementCopyWithImpl(this._self, this._then);

  final _Movement _self;
  final $Res Function(_Movement) _then;

/// Create a copy of Movement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? amount = null,Object? title = null,Object? place = null,Object? createdAt = null,Object? participants = freezed,}) {
  return _then(_Movement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as MovementType,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,place: null == place ? _self.place : place // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,participants: freezed == participants ? _self.participants : participants // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
