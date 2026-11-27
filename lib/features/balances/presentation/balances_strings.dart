import '../../../core/utils/money_format.dart';

/// Texts of the balances module (Colombian Spanish).
abstract final class BalancesStrings {
  // List
  static const String title = 'Saldos';
  static const String allGroups = 'Todos los grupos';
  static const String netBalance = 'Balance neto';
  static String inFavor(String scope) => 'A tu favor en $scope';
  static String against(String scope) => 'En contra en $scope';
  static String even(String scope) => 'Sin saldo en $scope';
  static String groupsScope(int count) =>
      count == 1 ? '1 grupo' : '$count grupos';
  static const String owedToYou = 'Te deben';
  static const String youOwe = 'Debes';
  static String people(int count) =>
      count == 1 ? '1 persona' : '$count personas';
  static const String nobody = 'nadie';
  static String barLabel(int owed, int owe) =>
      'Te deben ${MoneyFormat.format(owed)} y debes ${MoneyFormat.format(owe)}';
  static String owedSection(int count) => 'TE DEBEN · $count';
  static String oweSection(int count) => 'DEBES · $count';
  static String settledSection(int count) => 'A PAZ Y SALVO · $count';
  static const String owesYou = 'te debe';
  static const String youOweThem = 'le debes';
  static const String settled = 'a paz y salvo';
  static String pendingCount(int count) =>
      count == 1 ? '1 pendiente' : '$count pendientes';
  static String newCount(int count) =>
      count == 1 ? '1 movimiento nuevo' : '$count movimientos nuevos';
  static String groupCount(int count) =>
      count == 1 ? '1 grupo' : '$count grupos';
  static String handle(String nickname) => '@$nickname';
  static String lastActivity(String date) => 'último: $date';
  static const String noMovements = 'sin movimientos';
  static const String settledToggle = 'Personas sin saldo pendiente contigo';
  static const String hide = 'Ocultar';
  static String settledFootnote(String scope) =>
      'Aparecen aquí cuando no tienen nada pendiente contigo en $scope.';
  static const String allClearTitle = 'Todo en orden';
  static String allClearText(String scope) =>
      'Nadie te debe y no le debes a nadie en $scope.';
  static const String loading = 'Cargando saldos';
  static const String loadError = 'No pudimos cargar los saldos.';
  static const String retry = 'Reintentar';
  static String rowLabel(String name, int balance, int pending) {
    final amount = MoneyFormat.format(balance);
    final state = balance > 0
        ? 'te debe $amount'
        : balance < 0
        ? 'le debes $amount'
        : 'a paz y salvo';
    return pending == 0
        ? '$name, $state'
        : '$name, $state, ${pendingCount(pending)}';
  }

  // Person
  static const String back = 'Volver';
  static const String owesYouLabel = 'Te debe';
  static const String youOweLabel = 'Le debes';
  static const String settledTitle = 'A paz y salvo';
  static String lastMovement(String date) => 'Último movimiento: $date';
  static const String noMovementYet = 'Sin movimientos todavía';
  static String pendingSince(int count, String date) =>
      '${pendingCount(count)} · desde el $date';
  static const String remind = 'Recordarle';
  static String reminder({
    required String firstName,
    required int amount,
    required String scope,
    required List<String> accounts,
  }) {
    final base =
        'Hola $firstName, te recuerdo que tienes '
        '${MoneyFormat.format(amount)} pendientes conmigo en $scope.';
    return accounts.isEmpty
        ? base
        : '$base Mis cuentas: ${accounts.join(' · ')}';
  }

  static String pendingSection(int count) => 'PENDIENTES · $count';
  static const String noPending = 'No tienen nada pendiente.';
  static const String event = 'Evento';
  static const String direct = 'Directo';
  static const String payment = 'Pago';
  static const String rejected = 'Rechazado';
  static const String credit = 'Saldo a favor';
  static const String youPaidBill = 'pagaste tú';
  static String paidBill(String name) => 'pagó $name';
  static String ofTotal(int total) => 'de ${MoneyFormat.format(total)}';
  static const String partiallyPaid = 'abonó';
  static String pendingLabel({
    required String title,
    required String kind,
    required String date,
    required int remaining,
    required int original,
  }) => remaining == original
      ? '$title, $kind, $date, ${MoneyFormat.format(remaining)}'
      : '$title, $kind, $date, falta ${MoneyFormat.format(remaining)} '
            'de ${MoneyFormat.format(original)}';
  static String accountsOf(String firstName) =>
      'CUENTAS DE ${firstName.toUpperCase()}';
  static String copied(String reference) => 'Copiado · $reference';
  static String copyAccount(String name) => 'Copiar $name';
  static const String history = 'HISTORIAL';
  static const String seeAll = 'Ver todo';
  static const String filterAll = 'Todo';
  static const String filterEvents = 'Eventos';
  static const String filterDirect = 'Directos';
  static const String filterPayments = 'Pagos';
  static const String noHistory = 'Todavía no hay movimientos.';
  static String historyStart(String firstName, String group, String date) =>
      'Inicio del historial · $firstName entró a $group el $date';
  static const String historyStartShort = 'Inicio del historial';
  static const String loadingHistory = 'Cargando movimientos';
  static const String loadingMore = 'Cargando más movimientos';
  static const String historyError = 'No pudimos cargar los movimientos.';
  static const String loadMoreError = 'No pudimos cargar más movimientos.';
  static const String registerDebt = 'Registrar deuda';
  static const String registerPayment = 'Registrar pago';
  static const String newDot = 'nuevo';

  // History rows
  static String paidYou(String firstName) => '$firstName te pagó';
  static String partialPaidYou(String firstName) => '$firstName te abonó';
  static const String youPaid = 'Le pagaste';
  static String appliedTo(String title) => 'A $title';
  static String participants(int count) => '$count personas';
  static const String settledDebt = 'saldada';
  static const String registeredByYou = 'lo registraste tú';
  static String registeredBy(String firstName) => 'Lo registró $firstName';
  static String rejectedByYou(String when) => 'Lo rechazaste · $when';
  static String rejectedBy(String firstName, String when) =>
      'Lo rechazó $firstName · $when';
  static const String attachment = 'con imagen adjunta';
  static const String rejectedState = 'rechazado';

  // Sheets
  static String theyPaidYou(String firstName) => '$firstName te pagó';
  static String youPaidThem(String firstName) => 'Le pagaste a $firstName';
  static const String amount = 'Monto';
  static String all(int amount) => 'Todo · ${MoneyFormat.format(amount)}';
  static const String otherAmount = 'Otro monto';
  static const String amountRequired = 'Escribe un monto.';
  static String amountTooHigh(int max) =>
      'No puede ser mayor que lo pendiente (${MoneyFormat.format(max)}).';
  static String amountTooHighDebt(int max) =>
      'No puede ser mayor que ${MoneyFormat.format(max)}.';
  static const String appliesTo = 'SE APLICA A';
  static String appliesPartially(int amount) =>
      'abona ${MoneyFormat.format(amount)}';
  static const String balanceSuffix = 'saldo';
  static const String whichOfYours = '¿A CUÁL DE TUS CUENTAS TE PAGÓ?';
  static const String whichOfTheirs = '¿A CUÁL DE SUS CUENTAS LE PAGASTE?';
  static const String cash = 'Efectivo';
  static const String inPerson = 'En persona';
  static String paymentNotice(String firstName) =>
      'Se aplica de inmediato. $firstName puede rechazarlo si no le llegó.';
  static String registerPaymentAmount(int amount) =>
      'Registrar pago · ${MoneyFormat.format(amount)}';
  static String paymentRegistered(int amount) =>
      'Pago registrado · ${MoneyFormat.format(amount)}';
  static const String saving = 'Guardando';
  static String with_(String name) => 'Con $name';
  static String theyOweMe(String firstName) => '$firstName me debe';
  static const String iOweThem = 'Yo le debo';
  static const String concept = 'Concepto';
  static const String conceptHint = 'Ej. Taxi, almuerzo';
  static const String conceptRequired = 'Escribe un concepto.';
  static const String conceptTooLong = 'Máximo 60 caracteres.';
  static const String eventOptional = 'Evento (opcional)';
  static const String noEvent = 'Sin evento · deuda directa';
  static const String chooseEvent = 'Elige el evento';
  static const String date = 'Fecha';
  static String today(String date) => 'Hoy, $date';
  static const String futureDate = 'La fecha no puede ser futura.';
  static const String group = 'Grupo';
  static String debtNotice(String firstName) =>
      'Se suma al saldo de inmediato. $firstName puede rechazarla si no es '
      'correcta.';
  static const String debtRegistered = 'Deuda registrada';

  // Attachment
  static const String attach = 'Adjuntar imagen';
  static const String attachHint = 'Comprobante, recibo o foto · opcional';
  static const String takePhoto = 'Tomar foto';
  static const String fromGallery = 'Elegir de la galería';
  static String attachmentInfo(String size) => '$size · toca para ver';
  static const String removeAttachment = 'Quitar imagen';
  static const String attachmentLabel = 'Imagen adjunta, toca para ampliar';
  static const String attachmentSection = 'IMAGEN ADJUNTA';
  static const String closeViewer = 'Cerrar';
  static const String uploadFailed =
      'No pudimos subir la imagen. Intenta de nuevo.';
  static const String imageTooLarge =
      'La imagen pesa más de 1 MB. Prueba con otra.';
  static const String imageUnavailable = 'No pudimos cargar la imagen.';

  // Movement detail
  static String theyRegisteredPayment(String firstName) =>
      '$firstName registró un pago';
  static String theyRegisteredDebt(String firstName) =>
      '$firstName registró una deuda';
  static const String youRegisteredPayment = 'Registraste un pago';
  static const String youRegisteredDebt = 'Registraste una deuda';
  static String appliedNow(String when) => '$when · ya se aplicó a tu saldo';
  static String rejectedOn(String when) => '$when · rechazado';
  static const String appliedToLabel = 'Se aplicó a';
  static const String saysPaidTo = 'Dice que pagó a';
  static const String paidTo = 'Pagado a';
  static const String concepto = 'Concepto';
  static const String eventLabel = 'Evento';
  static const String note = 'Nota';
  static const String reason = 'Motivo';
  static String rejectHintPayment(String firstName, int amount) =>
      'Si no te llegó, recházalo y $firstName volverá a deberte '
      '${MoneyFormat.format(amount)}.';
  static String rejectHintDebt(String firstName) =>
      'Si no es correcta, recházala y se quitará de tu saldo con $firstName.';
  static const String reject = 'Rechazar';
  static const String gotIt = 'Entendido';
  static const String delete = 'Eliminar';
  static const String close = 'Cerrar';

  // Reject dialog
  static String rejectPaymentTitle(String firstName) =>
      '¿Rechazar el pago de $firstName?';
  static String rejectDebtTitle(String firstName) =>
      '¿Rechazar la deuda de $firstName?';
  static String rejectPaymentText(String firstName, int amount) =>
      'Se cancela el ajuste: $firstName vuelve a deberte '
      '${MoneyFormat.format(amount)} y le avisamos para que lo revise.';
  static String rejectDebtText(String firstName, int amount) =>
      'Se cancela el ajuste: se quitan ${MoneyFormat.format(amount)} de tu '
      'saldo con $firstName y le avisamos para que lo revise.';
  static const String reasonLabel = 'MOTIVO';
  static const String reasonNotReceived = 'No me llegó';
  static const String reasonWrongAmount = 'Monto equivocado';
  static const String reasonOther = 'Otro motivo';
  static const String otherReasonHint = 'Cuéntale qué pasó (opcional)';
  static const String cancel = 'Cancelar';
  // TODO: FCM — notify the author ("{name} rechazó tu pago de $ X").
  static String paymentRejected(String firstName) =>
      'Pago rechazado · $firstName ya fue avisado';
  static String debtRejected(String firstName) =>
      'Deuda rechazada · $firstName ya fue avisado';

  // Delete dialog
  static const String deleteTitle = '¿Eliminar este movimiento?';
  static const String deleteText =
      'Deja de contar para el saldo y queda en el registro del grupo.';
  static const String movementDeleted = 'Movimiento eliminado';

  // Quick movements (Home)
  static const String addMovement = 'Agregar movimiento';
  static const String income = 'Ingreso';
  static const String incomeText = 'Alguien te pagó';
  static const String paymentText = 'Le pagaste a alguien';
  static const String debt = 'Deuda';
  static const String debtText = 'Alguien te debe o le debes';
  static const String whoPaidYou = '¿Quién te pagó?';
  static const String whoDidYouPay = '¿A quién le pagaste?';
  static const String whoIsTheDebtWith = '¿Con quién es la deuda?';
  static String inGroup(String group) => 'En $group';
  static String nobodyOwesYou(String group) => 'Nadie te debe en $group.';
  static String youOweNobody(String group) => 'No le debes a nadie en $group.';
  static String noOtherMembers(String group) =>
      'Aún no hay más miembros en $group.';
  static String owesYouAmount(int amount) =>
      'te debe ${MoneyFormat.format(amount)}';
  static String youOweAmount(int amount) =>
      'le debes ${MoneyFormat.format(amount)}';

  // Failures
  static const String networkError =
      'Sin conexión. Revisa tu internet e intenta de nuevo.';
  static const String notAllowed =
      'Este movimiento ya cambió. Actualiza e intenta de nuevo.';
  static const String unknownError = 'Algo salió mal. Intenta de nuevo.';
}
