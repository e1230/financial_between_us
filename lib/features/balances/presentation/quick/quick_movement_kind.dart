/// What the Home quick actions register.
enum QuickMovementKind {
  /// Someone paid the user ("Agregar ingreso").
  income,

  /// The user paid someone ("Agregar pago").
  payment,

  /// A debt in either direction ("Agregar deuda").
  debt,
}
