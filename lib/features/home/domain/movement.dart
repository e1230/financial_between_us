import 'package:freezed_annotation/freezed_annotation.dart';

part 'movement.freezed.dart';

/// Kind of money movement, from the user's point of view.
enum MovementType {
  /// Someone paid the user.
  income,

  /// The user paid.
  payment,

  /// The user owes someone.
  debt,

  /// Someone owes the user.
  // DECISIÓN: a fourth kind, so a debt in the user's favor is not shown as
  // money already received.
  owed,
}

/// A money movement of a group that involves the user ("Últimos
/// movimientos").
@freezed
abstract class Movement with _$Movement {
  const factory Movement({
    required String id,
    required MovementType type,

    /// Whole pesos (COP), always positive; the sign comes from [type].
    required int amount,

    /// "@juliana te pagó".
    required String title,

    /// Place or event, like "Crepes & Waffles".
    required String place,
    required DateTime createdAt,

    /// People a payment was split among (`null` or 1: not split).
    int? participants,
  }) = _Movement;
}
