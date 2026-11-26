import '../domain/payment_account.dart';
import '../domain/payment_account_rules.dart';

/// User-facing texts of the payment accounts module (Spanish, Colombia).
abstract final class PaymentAccountsStrings {
  // List
  static const String title = 'Cuentas de pago';
  static const String subtitle = 'Compártelas cuando un amigo te vaya a pagar.';
  static const String back = 'Volver';
  static const String add = 'Agregar cuenta';
  static const String hint =
      'Mantén presionada una cuenta para copiar su referencia.';
  static const String loading = 'Cargando tus cuentas';
  static const String loadError = 'No pudimos cargar tus cuentas.';
  static const String retry = 'Reintentar';
  static const String cashReference = 'Pago en efectivo';
  static const String copyAction = 'Copiar referencia';
  static const String rowHint = 'Toca para ver, mantén presionado para copiar';
  static const String rowCopyHint = 'Toca para copiar';

  // Someone else's accounts (from the group detail)
  static String memberTitle(String firstName) => 'Cuentas de $firstName';
  static const String memberTitleFallback = 'Sus cuentas';
  static const String memberSubtitle = 'Toca una cuenta para copiarla.';
  static String memberEmpty(String firstName) =>
      '$firstName aún no tiene cuentas de pago.';
  static const String memberEmptyFallback = 'Aún no tiene cuentas de pago.';
  static const String memberLoadError = 'No pudimos cargar sus cuentas.';
  static const String memberLoading = 'Cargando sus cuentas';

  // Empty state
  static const String emptyTitle = 'Aún no tienes cuentas';
  static const String emptyText =
      'Agrega tu Nequi, Daviplata o llave Bre-B para que tus amigos te '
      'paguen fácil.';

  // Toasts
  static String copied(String reference) => 'Copiado · $reference';
  static const String cashNotCopied = 'Efectivo no tiene referencia';
  static const String saved = 'Cuenta guardada';
  static const String updated = 'Cambios guardados';
  static const String deleted = 'Cuenta eliminada';
  static const String limitReached =
      'Llegaste al máximo de ${PaymentAccountRules.maxAccounts} cuentas';
  static const String genericError = 'No pudimos guardar. Intenta de nuevo.';
  static const String networkError = 'Sin conexión. Intenta de nuevo.';
  static const String notFound = 'Esta cuenta ya no existe.';
  static const String shareError = 'No pudimos abrir Compartir.';

  // Detail
  static const String moreOptions = 'Más opciones';
  static const String phoneLabel = 'NÚMERO DE CELULAR';
  static const String referenceLabel = 'REFERENCIA';
  static String keyChip(BrebKeyType keyType) => 'Llave · ${keyType.label}';
  static const String cashTitle = 'Pago en efectivo';
  static const String cashText =
      'No hay número que copiar. Compártelo para avisar que recibes '
      'efectivo.';
  static const String copy = 'Copiar';
  static const String copiedButton = 'Copiado';
  static const String share = 'Compartir';
  static const String edit = 'Editar';
  static const String delete = 'Eliminar';

  // Delete dialog
  static String deleteTitle(String name) => '¿Eliminar “$name”?';
  static const String deleteText =
      'Ya no aparecerá en tu lista. Puedes volver a agregarla cuando '
      'quieras.';
  static const String cancel = 'Cancelar';

  // Form
  static const String newTitle = 'Nueva cuenta';
  static const String editTitle = 'Editar cuenta';
  static const String close = 'Cerrar';
  static const String nameLabel = 'Nombre';
  static const String nameHint = 'Ej. Nequi personal';
  static const String typeLabel = 'Tipo';
  static const String typeHint = 'Elige un tipo';
  static const String keyTypeLabel = 'Tipo de llave';
  static const String referenceFieldLabel = 'Referencia';
  static const String referenceNoType = 'Primero elige un tipo';
  static const String referenceNoKey = 'Elige el tipo de llave';
  static const String phoneFieldLabel = 'Número de celular';
  static const String keyFieldLabel = 'Llave';
  static const String otherFieldLabel = 'Número o referencia';
  static const String phoneHint = '300 123 4567';
  static const String emailHint = 'nombre@correo.com';
  static const String documentHint = '1020304050';
  static const String aliasHint = '@tullave';
  static const String otherHint = 'Ej. Ahorros 123-456789-00';
  static const String aliasHelper = 'Empieza por @. Ej. @tullave';
  static const String save = 'Guardar';
  static const String saving = 'Guardando';
  static const String discardTitle = '¿Descartar los cambios?';
  static const String discard = 'Descartar';
  static const String keepEditing = 'Seguir editando';

  // Errors
  static const String nameEmpty = 'Escribe un nombre.';
  static const String nameTooLong = 'Usa máximo 40 caracteres.';

  static String nameError(NameError error) => switch (error) {
    NameError.empty => nameEmpty,
    NameError.tooLong => nameTooLong,
  };

  static String referenceError(ReferenceError error) => switch (error) {
    ReferenceError.empty => 'Escribe la referencia.',
    ReferenceError.phoneLength => 'Revisa el número: debe tener 10 dígitos',
    ReferenceError.phonePrefix => 'Revisa el número: debe empezar por 3',
    ReferenceError.email => 'Revisa el correo.',
    ReferenceError.document => 'Revisa el documento: de 6 a 10 dígitos.',
    ReferenceError.alias =>
      'La llave debe empezar por @ y tener de 3 a 20 caracteres.',
    ReferenceError.tooShort => 'Escribe al menos 4 caracteres.',
  };

  /// "{nombre}, {tipo}, {referencia}" for screen readers.
  static String rowLabel(PaymentAccount account) {
    final reference = account.hasReference ? account.reference : cashReference;
    return '${account.name}, ${account.type.label}, $reference';
  }

  /// Text shared from the detail: "Nequi · 300 123 4567 · Mauricio", or
  /// "Recibo pago en efectivo · Mauricio" for cash. Without a name, the
  /// last part is left out.
  static String shareText(PaymentAccount account, String firstName) {
    final parts = account.hasReference
        ? [account.type.label, PaymentAccountRules.displayReference(account)]
        : ['Recibo pago en efectivo'];
    return [...parts, if (firstName.isNotEmpty) firstName].join(' · ');
  }

  /// Name given to a new account when its type is picked with the name
  /// still empty (`null`: none for "Otro").
  static String? defaultName(PaymentAccountType type) => switch (type) {
    PaymentAccountType.nequi => 'Nequi',
    PaymentAccountType.breb => 'Llave Bre-B',
    PaymentAccountType.daviplata => 'Daviplata',
    PaymentAccountType.cash => 'Efectivo',
    PaymentAccountType.other => null,
  };
}

/// Spanish names of the account types.
extension PaymentAccountTypeLabel on PaymentAccountType {
  String get label => switch (this) {
    PaymentAccountType.breb => 'Bre-B',
    PaymentAccountType.nequi => 'Nequi',
    PaymentAccountType.daviplata => 'Daviplata',
    PaymentAccountType.cash => 'Efectivo',
    PaymentAccountType.other => 'Otro',
  };

  /// What screen readers say for its logo.
  String get logoLabel => switch (this) {
    PaymentAccountType.cash || PaymentAccountType.other => label,
    _ => 'Logo de $label',
  };
}

/// Spanish names of the Bre-B key types.
extension BrebKeyTypeLabel on BrebKeyType {
  String get label => switch (this) {
    BrebKeyType.phone => 'Celular',
    BrebKeyType.email => 'Correo',
    BrebKeyType.document => 'Documento',
    BrebKeyType.alias => 'Alfanumérica',
  };
}
