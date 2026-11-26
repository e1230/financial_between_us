import '../../groups/domain/group_failure.dart';
import '../../groups/domain/group_validators.dart';

/// User-facing texts of the Home module (Colombian Spanish).
abstract final class HomeStrings {
  // Tabs
  static const String tabHome = 'Inicio';
  static const String tabEvents = 'Eventos';
  static const String tabBalances = 'Saldos';
  static const String tabProfile = 'Perfil';
  static const String add = 'Agregar';
  static const String closeAdd = 'Cerrar opciones';
  static const String unavailable = 'No disponible sin un grupo';

  // Header
  static const String openMenu = 'Abrir menú';
  static const String accounts = 'Cuentas';
  static const String noGroup = 'Sin grupo';
  static String groupPill(String name) =>
      'Grupo actual: $name. Cambiar de grupo';
  static const String groupPillEmpty = 'Sin grupo. Crear o unirte a un grupo';

  // No groups
  static const String emptyTitle = 'Arma tu primer grupo';
  static const String emptyText =
      'Crea uno nuevo o únete con el código que te compartió un amigo.';
  static const String createCardTitle = 'Crear un grupo';
  static const String createCardText =
      'Invita a tus amigos y lleven las cuentas juntos.';
  static const String joinCardTitle = 'Unirme a un grupo';
  static const String joinCardText = 'Usa el código que te compartieron.';

  // With a group
  static String greeting(String name) => 'Hola, $name';
  static const String periodWeek = 'Semana';
  static const String periodMonth = 'Mes';
  static const String periodSixMonths = '6 meses';
  static const String periodLabel = 'Periodo del gráfico';
  static const String paid = 'Pagado';
  static const String owedToYou = 'Te deben';
  static const String youOwe = 'Debes';
  static String chartSemantics({
    required String paid,
    required String owedToYou,
    required String youOwe,
  }) =>
      'Gráfico del periodo. Pagado: $paid. Te deben: $owedToYou. '
      'Debes: $youOwe.';
  static const String addIncome = 'Agregar ingreso';
  static const String addPayment = 'Agregar pago';
  static const String addDebt = 'Agregar deuda';
  static const String recentTitle = 'Últimos movimientos';
  static const String seeAll = 'Ver todo';
  static const String loadingMovements = 'Cargando movimientos';
  static const String loadingChart = 'Cargando gráfico';
  static const String noMovements = 'Aún no hay movimientos en este grupo.';
  static const String movementsError = 'No pudimos cargar los movimientos.';
  static const String groupsError = 'No pudimos cargar tus grupos.';
  static const String retry = 'Reintentar';
  static const String income = 'Ingreso';
  static const String payment = 'Pago';
  static const String debt = 'Deuda';
  static String people(int count) => '$count personas';

  // + popover
  static const String addEvent = 'Agregar evento';
  static const String addEventText = 'Comida, viaje o plan del grupo';
  static const String addMovement = 'Agregar movimiento';
  static const String addMovementText = 'Ingreso, pago o deuda';

  // Group selector
  static const String yourGroups = 'TUS GRUPOS';
  static const String noGroupsYet = 'Aún no estás en ningún grupo.';
  static String members(int count) =>
      count == 1 ? '1 miembro' : '$count miembros';
  static const String youAdmin = 'Administras';
  static const String awaitingApproval = 'Esperando aprobación';
  static const String createGroup = 'Crear grupo';
  static const String joinWithCode = 'Unirme con un código';

  // Avatar menu
  static const String closeMenu = 'Cerrar menú';
  static const String menuGroups = 'Grupos';
  static String menuGroupsText(String? active, int others) {
    if (active == null) return 'Aún no tienes grupos';
    return others == 0 ? active : '$active y $others más';
  }

  static const String menuAccountsText = 'Tus cuentas para recibir pagos';
  static const String menuEvents = 'Eventos';
  static const String menuEventsText = 'Planes y salidas de tus grupos';
  static const String menuBalances = 'Saldos';
  static const String menuBalancesText = 'Quién le debe a quién';
  static const String signOut = 'Cerrar sesión';
  static const String signOutTitle = '¿Cerrar sesión?';
  static const String signOutText =
      'Tendrás que volver a entrar con tu usuario o correo.';
  static const String signingOut = 'Cerrando sesión';
  static const String signOutError =
      'No pudimos cerrar la sesión. Inténtalo de nuevo.';
  static String version(String version) =>
      'Financial Between Us · versión $version';

  // Dialogs
  static const String cancel = 'Cancelar';
  static const String createTitle = 'Crear grupo';
  static const String createSubtitle = 'Tus amigos se unirán con un código.';
  static const String groupName = 'Nombre del grupo';
  static const String groupNameHint = 'ej. Low IQ Group';
  static const String optionalPassword = 'Contraseña (opcional)';
  static const String optionalPasswordHint = 'Sin contraseña';
  static const String optionalPasswordHelper =
      'Si la pones, se pedirá al unirse.';
  static const String approveMembers = 'Aprobar nuevos miembros';
  static const String approveMembersText = 'Tú decides quién entra al grupo.';
  static const String creating = 'Creando grupo';
  static const String createdTitle = 'Grupo creado';
  static String createdText(String name) =>
      'Comparte este código para que tus amigos se unan a $name.';
  static const String copy = 'Copiar';
  static const String copied = 'Copiado';
  static const String copyCode = 'Copiar código';
  static const String codeCopied = 'Código copiado al portapapeles.';
  static const String alsoPassword =
      'También necesitarán la contraseña del grupo.';
  static const String done = 'Listo';
  static const String joinTitle = 'Unirme a un grupo';
  static const String joinSubtitle = 'Escribe el código que te compartieron.';
  static const String groupCode = 'Código del grupo';
  static const String groupCodeHint = 'ej. LIQ-7K4P';
  static const String groupCodeHelper =
      'Si el grupo tiene contraseña, te la pediremos después.';
  static const String join = 'Unirme';
  static const String joining = 'Uniéndote al grupo';
  static const String passwordTitle = 'Contraseña del grupo';
  static String passwordSubtitle(String name) =>
      '$name pide una contraseña para entrar.';
  static const String password = 'Contraseña';
  static const String requestSentTitle = 'Solicitud enviada';
  static String requestSentText(String name) =>
      'Un administrador de $name debe aprobarte. Te avisaremos cuando entres.';
  static const String understood = 'Entendido';

  /// Message of a field failure.
  static String field(GroupFieldFailure failure) => switch (failure) {
    GroupFieldRequired() => 'Este campo es obligatorio.',
    GroupNameTooShort() =>
      'Usa al menos ${GroupValidators.minNameLength} caracteres.',
    GroupNameTooLong() =>
      'Usa máximo ${GroupValidators.maxNameLength} caracteres.',
    GroupPasswordTooShort() =>
      'Usa al menos ${GroupValidators.minPasswordLength} caracteres.',
    GroupCodeMalformed() => 'El código es como LIQ-7K4P.',
  };

  /// Message of a request failure.
  static String failure(GroupFailure failure) => switch (failure) {
    GroupCodeNotFound() => 'No encontramos un grupo con ese código.',
    AlreadyMember() => 'Ya estás en este grupo.',
    WrongGroupPassword() => 'La contraseña no coincide.',
    CodeGenerationExhausted() =>
      'No pudimos generar un código. Inténtalo de nuevo.',
    GroupNetworkFailure() => 'Sin conexión. Revisa tu internet.',
    UnknownGroupFailure() => 'Algo salió mal. Inténtalo de nuevo.',
  };
}
