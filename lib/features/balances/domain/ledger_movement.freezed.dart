// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ledger_movement.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PaymentApplication {

 String get targetId;/// Whole pesos, always positive.
 int get amount;
/// Create a copy of PaymentApplication
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaymentApplicationCopyWith<PaymentApplication> get copyWith => _$PaymentApplicationCopyWithImpl<PaymentApplication>(this as PaymentApplication, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as PaymentApplication;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaymentApplication&&(identical(other.targetId, _this.targetId) || other.targetId == _this.targetId)&&(identical(other.amount, _this.amount) || other.amount == _this.amount));
}


@override
int get hashCode {
  final _this = this as PaymentApplication;
  return Object.hash(runtimeType,_this.targetId,_this.amount);
}

@override
String toString() {
  final _this = this as PaymentApplication;
  return 'PaymentApplication(targetId: ${_this.targetId}, amount: ${_this.amount})';
}


}

/// @nodoc
abstract mixin class $PaymentApplicationCopyWith<$Res>  {
  factory $PaymentApplicationCopyWith(PaymentApplication value, $Res Function(PaymentApplication) _then) = _$PaymentApplicationCopyWithImpl;
@useResult
$Res call({
 String targetId, int amount
});




}
/// @nodoc
class _$PaymentApplicationCopyWithImpl<$Res>
    implements $PaymentApplicationCopyWith<$Res> {
  _$PaymentApplicationCopyWithImpl(this._self, this._then);

  final PaymentApplication _self;
  final $Res Function(PaymentApplication) _then;

/// Create a copy of PaymentApplication
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? targetId = null,Object? amount = null,}) {
  return _then(PaymentApplication(
targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaymentApplication].
extension PaymentApplicationPatterns on PaymentApplication {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaymentApplication value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaymentApplication() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaymentApplication value)  $default,){
final _that = this;
switch (_that) {
case _PaymentApplication():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaymentApplication value)?  $default,){
final _that = this;
switch (_that) {
case _PaymentApplication() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String targetId,  int amount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaymentApplication() when $default != null:
return $default(_that.targetId,_that.amount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String targetId,  int amount)  $default,) {final _that = this;
switch (_that) {
case _PaymentApplication():
return $default(_that.targetId,_that.amount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String targetId,  int amount)?  $default,) {final _that = this;
switch (_that) {
case _PaymentApplication() when $default != null:
return $default(_that.targetId,_that.amount);case _:
  return null;

}
}

}

/// @nodoc


class _PaymentApplication implements PaymentApplication {
  const _PaymentApplication({required this.targetId, required this.amount});
  

@override final  String targetId;
/// Whole pesos, always positive.
@override final  int amount;

/// Create a copy of PaymentApplication
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaymentApplicationCopyWith<_PaymentApplication> get copyWith => __$PaymentApplicationCopyWithImpl<_PaymentApplication>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaymentApplication&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.amount, amount) || other.amount == amount));
}


@override
int get hashCode {
    return Object.hash(runtimeType,targetId,amount);
}

@override
String toString() {
    return 'PaymentApplication(targetId: $targetId, amount: $amount)';
}


}

/// @nodoc
abstract mixin class _$PaymentApplicationCopyWith<$Res> implements $PaymentApplicationCopyWith<$Res> {
  factory _$PaymentApplicationCopyWith(_PaymentApplication value, $Res Function(_PaymentApplication) _then) = __$PaymentApplicationCopyWithImpl;
@override @useResult
$Res call({
 String targetId, int amount
});




}
/// @nodoc
class __$PaymentApplicationCopyWithImpl<$Res>
    implements _$PaymentApplicationCopyWith<$Res> {
  __$PaymentApplicationCopyWithImpl(this._self, this._then);

  final _PaymentApplication _self;
  final $Res Function(_PaymentApplication) _then;

/// Create a copy of PaymentApplication
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? targetId = null,Object? amount = null,}) {
  return _then(_PaymentApplication(
targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$AccountSnapshot {

 PaymentAccountType get type; String get name;/// Without format; empty for cash.
 String get reference;
/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AccountSnapshotCopyWith<AccountSnapshot> get copyWith => _$AccountSnapshotCopyWithImpl<AccountSnapshot>(this as AccountSnapshot, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as AccountSnapshot;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AccountSnapshot&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.reference, _this.reference) || other.reference == _this.reference));
}


@override
int get hashCode {
  final _this = this as AccountSnapshot;
  return Object.hash(runtimeType,_this.type,_this.name,_this.reference);
}

@override
String toString() {
  final _this = this as AccountSnapshot;
  return 'AccountSnapshot(type: ${_this.type}, name: ${_this.name}, reference: ${_this.reference})';
}


}

/// @nodoc
abstract mixin class $AccountSnapshotCopyWith<$Res>  {
  factory $AccountSnapshotCopyWith(AccountSnapshot value, $Res Function(AccountSnapshot) _then) = _$AccountSnapshotCopyWithImpl;
@useResult
$Res call({
 PaymentAccountType type, String name, String reference
});




}
/// @nodoc
class _$AccountSnapshotCopyWithImpl<$Res>
    implements $AccountSnapshotCopyWith<$Res> {
  _$AccountSnapshotCopyWithImpl(this._self, this._then);

  final AccountSnapshot _self;
  final $Res Function(AccountSnapshot) _then;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? type = null,Object? name = null,Object? reference = null,}) {
  return _then(AccountSnapshot(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentAccountType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AccountSnapshot].
extension AccountSnapshotPatterns on AccountSnapshot {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AccountSnapshot value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AccountSnapshot value)  $default,){
final _that = this;
switch (_that) {
case _AccountSnapshot():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AccountSnapshot value)?  $default,){
final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( PaymentAccountType type,  String name,  String reference)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
return $default(_that.type,_that.name,_that.reference);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( PaymentAccountType type,  String name,  String reference)  $default,) {final _that = this;
switch (_that) {
case _AccountSnapshot():
return $default(_that.type,_that.name,_that.reference);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( PaymentAccountType type,  String name,  String reference)?  $default,) {final _that = this;
switch (_that) {
case _AccountSnapshot() when $default != null:
return $default(_that.type,_that.name,_that.reference);case _:
  return null;

}
}

}

/// @nodoc


class _AccountSnapshot implements AccountSnapshot {
  const _AccountSnapshot({required this.type, required this.name, this.reference = ''});
  

@override final  PaymentAccountType type;
@override final  String name;
/// Without format; empty for cash.
@override@JsonKey() final  String reference;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AccountSnapshotCopyWith<_AccountSnapshot> get copyWith => __$AccountSnapshotCopyWithImpl<_AccountSnapshot>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _AccountSnapshot&&(identical(other.type, type) || other.type == type)&&(identical(other.name, name) || other.name == name)&&(identical(other.reference, reference) || other.reference == reference));
}


@override
int get hashCode {
    return Object.hash(runtimeType,type,name,reference);
}

@override
String toString() {
    return 'AccountSnapshot(type: $type, name: $name, reference: $reference)';
}


}

/// @nodoc
abstract mixin class _$AccountSnapshotCopyWith<$Res> implements $AccountSnapshotCopyWith<$Res> {
  factory _$AccountSnapshotCopyWith(_AccountSnapshot value, $Res Function(_AccountSnapshot) _then) = __$AccountSnapshotCopyWithImpl;
@override @useResult
$Res call({
 PaymentAccountType type, String name, String reference
});




}
/// @nodoc
class __$AccountSnapshotCopyWithImpl<$Res>
    implements _$AccountSnapshotCopyWith<$Res> {
  __$AccountSnapshotCopyWithImpl(this._self, this._then);

  final _AccountSnapshot _self;
  final $Res Function(_AccountSnapshot) _then;

/// Create a copy of AccountSnapshot
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? type = null,Object? name = null,Object? reference = null,}) {
  return _then(_AccountSnapshot(
type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as PaymentAccountType,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,reference: null == reference ? _self.reference : reference // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc
mixin _$MovementAttachment {

/// Cloudinary `secure_url`.
 String get url; int get width; int get height;/// Size of the uploaded file.
 int get bytes;
/// Create a copy of MovementAttachment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MovementAttachmentCopyWith<MovementAttachment> get copyWith => _$MovementAttachmentCopyWithImpl<MovementAttachment>(this as MovementAttachment, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as MovementAttachment;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MovementAttachment&&(identical(other.url, _this.url) || other.url == _this.url)&&(identical(other.width, _this.width) || other.width == _this.width)&&(identical(other.height, _this.height) || other.height == _this.height)&&(identical(other.bytes, _this.bytes) || other.bytes == _this.bytes));
}


@override
int get hashCode {
  final _this = this as MovementAttachment;
  return Object.hash(runtimeType,_this.url,_this.width,_this.height,_this.bytes);
}

@override
String toString() {
  final _this = this as MovementAttachment;
  return 'MovementAttachment(url: ${_this.url}, width: ${_this.width}, height: ${_this.height}, bytes: ${_this.bytes})';
}


}

/// @nodoc
abstract mixin class $MovementAttachmentCopyWith<$Res>  {
  factory $MovementAttachmentCopyWith(MovementAttachment value, $Res Function(MovementAttachment) _then) = _$MovementAttachmentCopyWithImpl;
@useResult
$Res call({
 String url, int width, int height, int bytes
});




}
/// @nodoc
class _$MovementAttachmentCopyWithImpl<$Res>
    implements $MovementAttachmentCopyWith<$Res> {
  _$MovementAttachmentCopyWithImpl(this._self, this._then);

  final MovementAttachment _self;
  final $Res Function(MovementAttachment) _then;

/// Create a copy of MovementAttachment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? url = null,Object? width = null,Object? height = null,Object? bytes = null,}) {
  return _then(MovementAttachment(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MovementAttachment].
extension MovementAttachmentPatterns on MovementAttachment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MovementAttachment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MovementAttachment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MovementAttachment value)  $default,){
final _that = this;
switch (_that) {
case _MovementAttachment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MovementAttachment value)?  $default,){
final _that = this;
switch (_that) {
case _MovementAttachment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String url,  int width,  int height,  int bytes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MovementAttachment() when $default != null:
return $default(_that.url,_that.width,_that.height,_that.bytes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String url,  int width,  int height,  int bytes)  $default,) {final _that = this;
switch (_that) {
case _MovementAttachment():
return $default(_that.url,_that.width,_that.height,_that.bytes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String url,  int width,  int height,  int bytes)?  $default,) {final _that = this;
switch (_that) {
case _MovementAttachment() when $default != null:
return $default(_that.url,_that.width,_that.height,_that.bytes);case _:
  return null;

}
}

}

/// @nodoc


class _MovementAttachment implements MovementAttachment {
  const _MovementAttachment({required this.url, this.width = 0, this.height = 0, this.bytes = 0});
  

/// Cloudinary `secure_url`.
@override final  String url;
@override@JsonKey() final  int width;
@override@JsonKey() final  int height;
/// Size of the uploaded file.
@override@JsonKey() final  int bytes;

/// Create a copy of MovementAttachment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MovementAttachmentCopyWith<_MovementAttachment> get copyWith => __$MovementAttachmentCopyWithImpl<_MovementAttachment>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _MovementAttachment&&(identical(other.url, url) || other.url == url)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.bytes, bytes) || other.bytes == bytes));
}


@override
int get hashCode {
    return Object.hash(runtimeType,url,width,height,bytes);
}

@override
String toString() {
    return 'MovementAttachment(url: $url, width: $width, height: $height, bytes: $bytes)';
}


}

/// @nodoc
abstract mixin class _$MovementAttachmentCopyWith<$Res> implements $MovementAttachmentCopyWith<$Res> {
  factory _$MovementAttachmentCopyWith(_MovementAttachment value, $Res Function(_MovementAttachment) _then) = __$MovementAttachmentCopyWithImpl;
@override @useResult
$Res call({
 String url, int width, int height, int bytes
});




}
/// @nodoc
class __$MovementAttachmentCopyWithImpl<$Res>
    implements _$MovementAttachmentCopyWith<$Res> {
  __$MovementAttachmentCopyWithImpl(this._self, this._then);

  final _MovementAttachment _self;
  final $Res Function(_MovementAttachment) _then;

/// Create a copy of MovementAttachment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? url = null,Object? width = null,Object? height = null,Object? bytes = null,}) {
  return _then(_MovementAttachment(
url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,width: null == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int,height: null == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int,bytes: null == bytes ? _self.bytes : bytes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$LedgerMovement {

 String get id; String get groupId; LedgerMovementType get type;/// Who owes (in a payment: who pays).
 String get debtorUid;/// Who is owed (in a payment: who receives).
 String get creditorUid;/// Whole pesos (COP), always positive.
 int get amount;/// Only for debts.
 DebtKind get kind;/// Only for debts of an event.
 String? get eventId; String? get eventName;/// Debt: what it was for ("Taxi"). Payment: empty.
 String get concept;/// Only for payments: which pending items it settles.
 List<PaymentApplication> get appliedTo;/// Only for payments: where the money went.
 AccountSnapshot? get account; String? get note; MovementAttachment? get attachment;/// When it happened (chosen by the user).
 DateTime get date; String get createdBy;/// Set by the server; `null` while a local write is pending.
 DateTime? get createdAt; MovementStatus get status; DateTime? get rejectedAt; String? get rejectedBy; RejectReason? get rejectReason; String? get rejectNote; DateTime? get deletedAt;/// Users who already opened it (for the "new" dot).
 List<String> get seenBy;
/// Create a copy of LedgerMovement
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LedgerMovementCopyWith<LedgerMovement> get copyWith => _$LedgerMovementCopyWithImpl<LedgerMovement>(this as LedgerMovement, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as LedgerMovement;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LedgerMovement&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.groupId, _this.groupId) || other.groupId == _this.groupId)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.debtorUid, _this.debtorUid) || other.debtorUid == _this.debtorUid)&&(identical(other.creditorUid, _this.creditorUid) || other.creditorUid == _this.creditorUid)&&(identical(other.amount, _this.amount) || other.amount == _this.amount)&&(identical(other.kind, _this.kind) || other.kind == _this.kind)&&(identical(other.eventId, _this.eventId) || other.eventId == _this.eventId)&&(identical(other.eventName, _this.eventName) || other.eventName == _this.eventName)&&(identical(other.concept, _this.concept) || other.concept == _this.concept)&&const DeepCollectionEquality().equals(other.appliedTo, _this.appliedTo)&&(identical(other.account, _this.account) || other.account == _this.account)&&(identical(other.note, _this.note) || other.note == _this.note)&&(identical(other.attachment, _this.attachment) || other.attachment == _this.attachment)&&(identical(other.date, _this.date) || other.date == _this.date)&&(identical(other.createdBy, _this.createdBy) || other.createdBy == _this.createdBy)&&(identical(other.createdAt, _this.createdAt) || other.createdAt == _this.createdAt)&&(identical(other.status, _this.status) || other.status == _this.status)&&(identical(other.rejectedAt, _this.rejectedAt) || other.rejectedAt == _this.rejectedAt)&&(identical(other.rejectedBy, _this.rejectedBy) || other.rejectedBy == _this.rejectedBy)&&(identical(other.rejectReason, _this.rejectReason) || other.rejectReason == _this.rejectReason)&&(identical(other.rejectNote, _this.rejectNote) || other.rejectNote == _this.rejectNote)&&(identical(other.deletedAt, _this.deletedAt) || other.deletedAt == _this.deletedAt)&&const DeepCollectionEquality().equals(other.seenBy, _this.seenBy));
}


@override
int get hashCode {
  final _this = this as LedgerMovement;
  return Object.hashAll([runtimeType,_this.id,_this.groupId,_this.type,_this.debtorUid,_this.creditorUid,_this.amount,_this.kind,_this.eventId,_this.eventName,_this.concept,const DeepCollectionEquality().hash(_this.appliedTo),_this.account,_this.note,_this.attachment,_this.date,_this.createdBy,_this.createdAt,_this.status,_this.rejectedAt,_this.rejectedBy,_this.rejectReason,_this.rejectNote,_this.deletedAt,const DeepCollectionEquality().hash(_this.seenBy)]);
}

@override
String toString() {
  final _this = this as LedgerMovement;
  return 'LedgerMovement(id: ${_this.id}, groupId: ${_this.groupId}, type: ${_this.type}, debtorUid: ${_this.debtorUid}, creditorUid: ${_this.creditorUid}, amount: ${_this.amount}, kind: ${_this.kind}, eventId: ${_this.eventId}, eventName: ${_this.eventName}, concept: ${_this.concept}, appliedTo: ${_this.appliedTo}, account: ${_this.account}, note: ${_this.note}, attachment: ${_this.attachment}, date: ${_this.date}, createdBy: ${_this.createdBy}, createdAt: ${_this.createdAt}, status: ${_this.status}, rejectedAt: ${_this.rejectedAt}, rejectedBy: ${_this.rejectedBy}, rejectReason: ${_this.rejectReason}, rejectNote: ${_this.rejectNote}, deletedAt: ${_this.deletedAt}, seenBy: ${_this.seenBy})';
}


}

/// @nodoc
abstract mixin class $LedgerMovementCopyWith<$Res>  {
  factory $LedgerMovementCopyWith(LedgerMovement value, $Res Function(LedgerMovement) _then) = _$LedgerMovementCopyWithImpl;
@useResult
$Res call({
 String id, String groupId, LedgerMovementType type, String debtorUid, String creditorUid, int amount, DebtKind kind, String? eventId, String? eventName, String concept, List<PaymentApplication> appliedTo, AccountSnapshot? account, String? note, MovementAttachment? attachment, DateTime date, String createdBy, DateTime? createdAt, MovementStatus status, DateTime? rejectedAt, String? rejectedBy, RejectReason? rejectReason, String? rejectNote, DateTime? deletedAt, List<String> seenBy
});


$AccountSnapshotCopyWith<$Res>? get account;$MovementAttachmentCopyWith<$Res>? get attachment;

}
/// @nodoc
class _$LedgerMovementCopyWithImpl<$Res>
    implements $LedgerMovementCopyWith<$Res> {
  _$LedgerMovementCopyWithImpl(this._self, this._then);

  final LedgerMovement _self;
  final $Res Function(LedgerMovement) _then;

/// Create a copy of LedgerMovement
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? groupId = null,Object? type = null,Object? debtorUid = null,Object? creditorUid = null,Object? amount = null,Object? kind = null,Object? eventId = freezed,Object? eventName = freezed,Object? concept = null,Object? appliedTo = null,Object? account = freezed,Object? note = freezed,Object? attachment = freezed,Object? date = null,Object? createdBy = null,Object? createdAt = freezed,Object? status = null,Object? rejectedAt = freezed,Object? rejectedBy = freezed,Object? rejectReason = freezed,Object? rejectNote = freezed,Object? deletedAt = freezed,Object? seenBy = null,}) {
  return _then(LedgerMovement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LedgerMovementType,debtorUid: null == debtorUid ? _self.debtorUid : debtorUid // ignore: cast_nullable_to_non_nullable
as String,creditorUid: null == creditorUid ? _self.creditorUid : creditorUid // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DebtKind,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,concept: null == concept ? _self.concept : concept // ignore: cast_nullable_to_non_nullable
as String,appliedTo: null == appliedTo ? _self.appliedTo : appliedTo // ignore: cast_nullable_to_non_nullable
as List<PaymentApplication>,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as AccountSnapshot?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,attachment: freezed == attachment ? _self.attachment : attachment // ignore: cast_nullable_to_non_nullable
as MovementAttachment?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MovementStatus,rejectedAt: freezed == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectedBy: freezed == rejectedBy ? _self.rejectedBy : rejectedBy // ignore: cast_nullable_to_non_nullable
as String?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as RejectReason?,rejectNote: freezed == rejectNote ? _self.rejectNote : rejectNote // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,seenBy: null == seenBy ? _self.seenBy : seenBy // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}
/// Create a copy of LedgerMovement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountSnapshotCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $AccountSnapshotCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of LedgerMovement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovementAttachmentCopyWith<$Res>? get attachment {
    if (_self.attachment == null) {
    return null;
  }

  return $MovementAttachmentCopyWith<$Res>(_self.attachment!, (value) {
    return _then(_self.copyWith(attachment: value));
  });
}
}


/// Adds pattern-matching-related methods to [LedgerMovement].
extension LedgerMovementPatterns on LedgerMovement {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LedgerMovement value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LedgerMovement() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LedgerMovement value)  $default,){
final _that = this;
switch (_that) {
case _LedgerMovement():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LedgerMovement value)?  $default,){
final _that = this;
switch (_that) {
case _LedgerMovement() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String groupId,  LedgerMovementType type,  String debtorUid,  String creditorUid,  int amount,  DebtKind kind,  String? eventId,  String? eventName,  String concept,  List<PaymentApplication> appliedTo,  AccountSnapshot? account,  String? note,  MovementAttachment? attachment,  DateTime date,  String createdBy,  DateTime? createdAt,  MovementStatus status,  DateTime? rejectedAt,  String? rejectedBy,  RejectReason? rejectReason,  String? rejectNote,  DateTime? deletedAt,  List<String> seenBy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LedgerMovement() when $default != null:
return $default(_that.id,_that.groupId,_that.type,_that.debtorUid,_that.creditorUid,_that.amount,_that.kind,_that.eventId,_that.eventName,_that.concept,_that.appliedTo,_that.account,_that.note,_that.attachment,_that.date,_that.createdBy,_that.createdAt,_that.status,_that.rejectedAt,_that.rejectedBy,_that.rejectReason,_that.rejectNote,_that.deletedAt,_that.seenBy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String groupId,  LedgerMovementType type,  String debtorUid,  String creditorUid,  int amount,  DebtKind kind,  String? eventId,  String? eventName,  String concept,  List<PaymentApplication> appliedTo,  AccountSnapshot? account,  String? note,  MovementAttachment? attachment,  DateTime date,  String createdBy,  DateTime? createdAt,  MovementStatus status,  DateTime? rejectedAt,  String? rejectedBy,  RejectReason? rejectReason,  String? rejectNote,  DateTime? deletedAt,  List<String> seenBy)  $default,) {final _that = this;
switch (_that) {
case _LedgerMovement():
return $default(_that.id,_that.groupId,_that.type,_that.debtorUid,_that.creditorUid,_that.amount,_that.kind,_that.eventId,_that.eventName,_that.concept,_that.appliedTo,_that.account,_that.note,_that.attachment,_that.date,_that.createdBy,_that.createdAt,_that.status,_that.rejectedAt,_that.rejectedBy,_that.rejectReason,_that.rejectNote,_that.deletedAt,_that.seenBy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String groupId,  LedgerMovementType type,  String debtorUid,  String creditorUid,  int amount,  DebtKind kind,  String? eventId,  String? eventName,  String concept,  List<PaymentApplication> appliedTo,  AccountSnapshot? account,  String? note,  MovementAttachment? attachment,  DateTime date,  String createdBy,  DateTime? createdAt,  MovementStatus status,  DateTime? rejectedAt,  String? rejectedBy,  RejectReason? rejectReason,  String? rejectNote,  DateTime? deletedAt,  List<String> seenBy)?  $default,) {final _that = this;
switch (_that) {
case _LedgerMovement() when $default != null:
return $default(_that.id,_that.groupId,_that.type,_that.debtorUid,_that.creditorUid,_that.amount,_that.kind,_that.eventId,_that.eventName,_that.concept,_that.appliedTo,_that.account,_that.note,_that.attachment,_that.date,_that.createdBy,_that.createdAt,_that.status,_that.rejectedAt,_that.rejectedBy,_that.rejectReason,_that.rejectNote,_that.deletedAt,_that.seenBy);case _:
  return null;

}
}

}

/// @nodoc


class _LedgerMovement extends LedgerMovement {
  const _LedgerMovement({required this.id, required this.groupId, required this.type, required this.debtorUid, required this.creditorUid, required this.amount, this.kind = DebtKind.direct, this.eventId, this.eventName, this.concept = '',  List<PaymentApplication> appliedTo = const <PaymentApplication>[], this.account, this.note, this.attachment, required this.date, required this.createdBy, this.createdAt, this.status = MovementStatus.active, this.rejectedAt, this.rejectedBy, this.rejectReason, this.rejectNote, this.deletedAt,  List<String> seenBy = const <String>[]}): _appliedTo = appliedTo,_seenBy = seenBy,super._();
  

@override final  String id;
@override final  String groupId;
@override final  LedgerMovementType type;
/// Who owes (in a payment: who pays).
@override final  String debtorUid;
/// Who is owed (in a payment: who receives).
@override final  String creditorUid;
/// Whole pesos (COP), always positive.
@override final  int amount;
/// Only for debts.
@override@JsonKey() final  DebtKind kind;
/// Only for debts of an event.
@override final  String? eventId;
@override final  String? eventName;
/// Debt: what it was for ("Taxi"). Payment: empty.
@override@JsonKey() final  String concept;
/// Only for payments: which pending items it settles.
 final  List<PaymentApplication> _appliedTo;
/// Only for payments: which pending items it settles.
@override@JsonKey() List<PaymentApplication> get appliedTo {
  if (_appliedTo is EqualUnmodifiableListView) return _appliedTo;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_appliedTo);
}

/// Only for payments: where the money went.
@override final  AccountSnapshot? account;
@override final  String? note;
@override final  MovementAttachment? attachment;
/// When it happened (chosen by the user).
@override final  DateTime date;
@override final  String createdBy;
/// Set by the server; `null` while a local write is pending.
@override final  DateTime? createdAt;
@override@JsonKey() final  MovementStatus status;
@override final  DateTime? rejectedAt;
@override final  String? rejectedBy;
@override final  RejectReason? rejectReason;
@override final  String? rejectNote;
@override final  DateTime? deletedAt;
/// Users who already opened it (for the "new" dot).
 final  List<String> _seenBy;
/// Users who already opened it (for the "new" dot).
@override@JsonKey() List<String> get seenBy {
  if (_seenBy is EqualUnmodifiableListView) return _seenBy;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_seenBy);
}


/// Create a copy of LedgerMovement
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LedgerMovementCopyWith<_LedgerMovement> get copyWith => __$LedgerMovementCopyWithImpl<_LedgerMovement>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _LedgerMovement&&(identical(other.id, id) || other.id == id)&&(identical(other.groupId, groupId) || other.groupId == groupId)&&(identical(other.type, type) || other.type == type)&&(identical(other.debtorUid, debtorUid) || other.debtorUid == debtorUid)&&(identical(other.creditorUid, creditorUid) || other.creditorUid == creditorUid)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.eventId, eventId) || other.eventId == eventId)&&(identical(other.eventName, eventName) || other.eventName == eventName)&&(identical(other.concept, concept) || other.concept == concept)&&const DeepCollectionEquality().equals(other.appliedTo, _appliedTo)&&(identical(other.account, account) || other.account == account)&&(identical(other.note, note) || other.note == note)&&(identical(other.attachment, attachment) || other.attachment == attachment)&&(identical(other.date, date) || other.date == date)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.status, status) || other.status == status)&&(identical(other.rejectedAt, rejectedAt) || other.rejectedAt == rejectedAt)&&(identical(other.rejectedBy, rejectedBy) || other.rejectedBy == rejectedBy)&&(identical(other.rejectReason, rejectReason) || other.rejectReason == rejectReason)&&(identical(other.rejectNote, rejectNote) || other.rejectNote == rejectNote)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&const DeepCollectionEquality().equals(other.seenBy, _seenBy));
}


@override
int get hashCode {
    return Object.hashAll([runtimeType,id,groupId,type,debtorUid,creditorUid,amount,kind,eventId,eventName,concept,const DeepCollectionEquality().hash(_appliedTo),account,note,attachment,date,createdBy,createdAt,status,rejectedAt,rejectedBy,rejectReason,rejectNote,deletedAt,const DeepCollectionEquality().hash(_seenBy)]);
}

@override
String toString() {
    return 'LedgerMovement(id: $id, groupId: $groupId, type: $type, debtorUid: $debtorUid, creditorUid: $creditorUid, amount: $amount, kind: $kind, eventId: $eventId, eventName: $eventName, concept: $concept, appliedTo: $appliedTo, account: $account, note: $note, attachment: $attachment, date: $date, createdBy: $createdBy, createdAt: $createdAt, status: $status, rejectedAt: $rejectedAt, rejectedBy: $rejectedBy, rejectReason: $rejectReason, rejectNote: $rejectNote, deletedAt: $deletedAt, seenBy: $seenBy)';
}


}

/// @nodoc
abstract mixin class _$LedgerMovementCopyWith<$Res> implements $LedgerMovementCopyWith<$Res> {
  factory _$LedgerMovementCopyWith(_LedgerMovement value, $Res Function(_LedgerMovement) _then) = __$LedgerMovementCopyWithImpl;
@override @useResult
$Res call({
 String id, String groupId, LedgerMovementType type, String debtorUid, String creditorUid, int amount, DebtKind kind, String? eventId, String? eventName, String concept, List<PaymentApplication> appliedTo, AccountSnapshot? account, String? note, MovementAttachment? attachment, DateTime date, String createdBy, DateTime? createdAt, MovementStatus status, DateTime? rejectedAt, String? rejectedBy, RejectReason? rejectReason, String? rejectNote, DateTime? deletedAt, List<String> seenBy
});


@override $AccountSnapshotCopyWith<$Res>? get account;@override $MovementAttachmentCopyWith<$Res>? get attachment;

}
/// @nodoc
class __$LedgerMovementCopyWithImpl<$Res>
    implements _$LedgerMovementCopyWith<$Res> {
  __$LedgerMovementCopyWithImpl(this._self, this._then);

  final _LedgerMovement _self;
  final $Res Function(_LedgerMovement) _then;

/// Create a copy of LedgerMovement
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? groupId = null,Object? type = null,Object? debtorUid = null,Object? creditorUid = null,Object? amount = null,Object? kind = null,Object? eventId = freezed,Object? eventName = freezed,Object? concept = null,Object? appliedTo = null,Object? account = freezed,Object? note = freezed,Object? attachment = freezed,Object? date = null,Object? createdBy = null,Object? createdAt = freezed,Object? status = null,Object? rejectedAt = freezed,Object? rejectedBy = freezed,Object? rejectReason = freezed,Object? rejectNote = freezed,Object? deletedAt = freezed,Object? seenBy = null,}) {
  return _then(_LedgerMovement(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,groupId: null == groupId ? _self.groupId : groupId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as LedgerMovementType,debtorUid: null == debtorUid ? _self.debtorUid : debtorUid // ignore: cast_nullable_to_non_nullable
as String,creditorUid: null == creditorUid ? _self.creditorUid : creditorUid // ignore: cast_nullable_to_non_nullable
as String,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as int,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as DebtKind,eventId: freezed == eventId ? _self.eventId : eventId // ignore: cast_nullable_to_non_nullable
as String?,eventName: freezed == eventName ? _self.eventName : eventName // ignore: cast_nullable_to_non_nullable
as String?,concept: null == concept ? _self.concept : concept // ignore: cast_nullable_to_non_nullable
as String,appliedTo: null == appliedTo ? _self._appliedTo : appliedTo // ignore: cast_nullable_to_non_nullable
as List<PaymentApplication>,account: freezed == account ? _self.account : account // ignore: cast_nullable_to_non_nullable
as AccountSnapshot?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,attachment: freezed == attachment ? _self.attachment : attachment // ignore: cast_nullable_to_non_nullable
as MovementAttachment?,date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as DateTime,createdBy: null == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MovementStatus,rejectedAt: freezed == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,rejectedBy: freezed == rejectedBy ? _self.rejectedBy : rejectedBy // ignore: cast_nullable_to_non_nullable
as String?,rejectReason: freezed == rejectReason ? _self.rejectReason : rejectReason // ignore: cast_nullable_to_non_nullable
as RejectReason?,rejectNote: freezed == rejectNote ? _self.rejectNote : rejectNote // ignore: cast_nullable_to_non_nullable
as String?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,seenBy: null == seenBy ? _self._seenBy : seenBy // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

/// Create a copy of LedgerMovement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AccountSnapshotCopyWith<$Res>? get account {
    if (_self.account == null) {
    return null;
  }

  return $AccountSnapshotCopyWith<$Res>(_self.account!, (value) {
    return _then(_self.copyWith(account: value));
  });
}/// Create a copy of LedgerMovement
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$MovementAttachmentCopyWith<$Res>? get attachment {
    if (_self.attachment == null) {
    return null;
  }

  return $MovementAttachmentCopyWith<$Res>(_self.attachment!, (value) {
    return _then(_self.copyWith(attachment: value));
  });
}
}

// dart format on
