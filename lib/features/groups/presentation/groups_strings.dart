import '../domain/group_validators.dart';

/// Visible texts of the "Grupos" page (Spanish, as the rest of the UI).
abstract final class GroupsStrings {
  static const String title = 'Grupos';
  static const String subtitle =
      'Crea un grupo, únete a uno con su código o sal de los que ya no uses.';
  static const String back = 'Volver';
  static const String openAccounts = 'Toca para ver sus cuentas de pago';
  static const String openMyAccounts = 'Toca para ver tus cuentas de pago';

  static String code(String code) => 'Código $code';
  static const String shownInHome = 'Se muestra en Inicio';
  static const String showInHome = 'Mostrar en Inicio';

  static const String empty =
      'Aún no estás en ningún grupo. Crea uno o únete con el código que te '
      'compartan.';
  static const String loading = 'Cargando grupos';
  static const String loadError = 'No pudimos cargar tus grupos.';

  // Leaving.
  static const String leave = 'Salir del grupo';
  static const String leaving = 'Saliendo del grupo';
  static String leaveTitle(String name) => '¿Salir de $name?';
  static const String leaveMemberText =
      'Dejarás de ver sus eventos y saldos. Para volver necesitarás su código.';
  static const String leaveTransferText =
      'Dejarás de ver sus eventos y saldos. La administración pasará al '
      'miembro más antiguo del grupo.';
  static const String leaveToAdminText =
      'Dejarás de ver sus eventos y saldos. La administración principal '
      'pasará al administrador más antiguo.';
  static const String leaveArchiveText =
      'Eres el único miembro: el grupo se archivará y su código dejará de '
      'funcionar.';

  // Withdrawing a pending request.
  static const String cancelRequest = 'Cancelar solicitud';
  static const String cancellingRequest = 'Cancelando solicitud';
  static String cancelRequestTitle(String name) =>
      '¿Cancelar tu solicitud a $name?';
  static const String cancelRequestText =
      'Si cambias de opinión, puedes volver a pedir entrar con el código.';
  static const String keepRequest = 'Mantener solicitud';

  // Group detail.
  static const String openDetail = 'Ver detalle';
  static String createdOn(String date) => 'Creado el $date';
  static const String youAdminGroup = 'Administras este grupo';
  static String adminBy(String nickname) => 'Administra @$nickname';
  static String adminByMany(String nickname, int others) =>
      'Administran @$nickname y $others más';
  static const String requiresApproval = 'Requiere aprobación';
  static const String withPassword = 'Con contraseña';
  static const String notMember = 'Ya no haces parte de este grupo.';
  static const String membersTitle = 'MIEMBROS';
  static const String pendingTitle = 'SOLICITUDES PENDIENTES';
  static const String membersError = 'No pudimos cargar los miembros.';
  static const String loadingMembers = 'Cargando miembros';
  static String you(String name) => '$name (tú)';
  static const String roleOwner = 'Administrador principal';
  static const String roleAdmin = 'Administrador';
  static const String roleMember = 'Miembro';
  static String since(String date) => 'Desde el $date';
  static String requestedOn(String date) => 'Pidió entrar el $date';

  // Balance with a member.
  static const String owesYou = 'Te debe';
  static const String youOwe = 'Debes';
  static const String even = 'Están a mano';

  // Editing the group (admins).
  static const String editGroup = 'Editar grupo';
  static const String editSubtitle =
      'Los cambios aplican para todos los miembros.';
  static const String approveMembersText =
      'Un administrador decide quién entra al grupo.';
  static const String askPassword = 'Pedir contraseña';
  static const String askPasswordText = 'Se pedirá al unirse con el código.';
  static const String newPassword = 'Nueva contraseña';
  static const String keepPasswordHint = 'Vacía para mantener la actual';
  static const String passwordHint =
      'Mínimo ${GroupValidators.minPasswordLength} caracteres';
  static const String changePasswordHelper =
      'Si la cambias, la anterior dejará de funcionar.';
  static const String saveChanges = 'Guardar cambios';
  static const String saving = 'Guardando cambios';

  // Admin actions.
  static String memberOptions(String name) => 'Opciones de $name';
  static const String memberOptionsText = '¿Qué quieres hacer?';
  static const String promote = 'Hacer administrador';
  static const String promoting = 'Haciendo administrador';
  static String promoteTitle(String name) => '¿Hacer administrador a $name?';
  static const String promoteText =
      'Podrá aprobar y rechazar solicitudes, eliminar miembros y nombrar '
      'otros administradores.';
  static const String demote = 'Quitar como administrador';
  static const String demoting = 'Quitando como administrador';
  static String demoteTitle(String name) =>
      '¿Quitarle la administración a $name?';
  static const String demoteText = 'Seguirá en el grupo como miembro.';
  static const String removeMember = 'Eliminar del grupo';
  static const String removing = 'Eliminando del grupo';
  static String removeTitle(String name) => '¿Eliminar a $name del grupo?';
  static const String removeText =
      'Dejará de ver sus eventos y saldos. Podrá volver a entrar con el '
      'código.';
  static const String pendingBalanceWarning =
      'Tiene saldos pendientes en el grupo. Se seguirán calculando con el '
      'historial.';
  static const String approve = 'Aprobar';
  static const String approving = 'Aprobando solicitud';
  static String approveOf(String name) => 'Aprobar a $name';
  static const String reject = 'Rechazar';
  static const String rejecting = 'Rechazando solicitud';
  static String rejectOf(String name) => 'Rechazar a $name';
  static String rejectTitle(String name) => '¿Rechazar la solicitud de $name?';
  static const String rejectText =
      'No entrará al grupo. Podrá volver a pedirlo con el código.';
}
