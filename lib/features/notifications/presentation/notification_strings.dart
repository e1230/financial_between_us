import '../../../core/utils/money_format.dart';
import '../../balances/domain/ledger_movement.dart';
import '../../balances/presentation/balances_strings.dart';

/// Visible texts of the push notifications.
abstract final class NotificationStrings {
  // Android notification channels (Ajustes → Notificaciones).
  static const String movementsChannel = 'Pagos y deudas';
  static const String movementsChannelDescription =
      'Pagos, ingresos y deudas que otros registran contigo.';
  static const String groupsChannel = 'Grupos';
  static const String groupsChannelDescription =
      'Quién entra, pide entrar o sale de tus grupos.';

  // Actions of a new movement.
  static const String confirm = 'Confirmar';
  static const String reject = 'Rechazar';

  static String _amount(int pesos) => MoneyFormat.format(pesos);

  static String _with(String first, String fallback) =>
      first.isEmpty ? fallback : first;

  static const String _someone = 'Alguien';

  // A new movement, from the recipient's side.
  static String paidYou(String first) =>
      '${_with(first, _someone)} te registró un pago';
  static String registeredYourPayment(String first) =>
      '${_with(first, _someone)} registró tu pago';
  static String youOwe(String first) =>
      '${_with(first, _someone)} registró que le debes';
  static String owesYou(String first) =>
      '${_with(first, _someone)} registró que te debe';

  static String newMovementBody({
    required int amount,
    required String concept,
    required String group,
  }) => [
    _amount(amount),
    if (concept.isNotEmpty) concept,
    if (group.isNotEmpty) group,
  ].join(' · ');

  static const String appliedHint =
      'Ya se aplicó a tu saldo. Si no es correcto, recházalo.';

  // A rejected movement, for its author.
  static String rejectedPayment(String first) =>
      '${_with(first, _someone)} rechazó tu pago';
  static String rejectedDebt(String first) =>
      '${_with(first, _someone)} rechazó la deuda que registraste';

  static String rejectedBody({
    required int amount,
    required String group,
    required RejectReason? reason,
  }) {
    final why = switch (reason) {
      RejectReason.notReceived => BalancesStrings.reasonNotReceived,
      RejectReason.wrongAmount => BalancesStrings.reasonWrongAmount,
      RejectReason.other => BalancesStrings.reasonOther,
      null => null,
    };
    return [
      _amount(amount),
      if (group.isNotEmpty) group,
      if (why != null) 'Motivo: $why',
    ].join(' · ');
  }

  // A deleted movement, for the other party.
  static String deletedPayment(String first) =>
      '${_with(first, _someone)} eliminó un pago';
  static String deletedDebt(String first) =>
      '${_with(first, _someone)} eliminó una deuda';

  static String deletedBody({required int amount, required String group}) => [
    _amount(amount),
    if (group.isNotEmpty) group,
    'Ya no cuenta en tu saldo',
  ].join(' · ');

  // Membership.
  static String newMemberTitle(String group) => 'Nuevo integrante en $group';
  static String joinedBody(String first) =>
      '${_with(first, _someone)} entró al grupo.';

  static String requestTitle(String group) => 'Solicitud para unirse a $group';
  static String requestBody(String first) =>
      '${_with(first, _someone)} quiere entrar al grupo. Apruébalo o recházalo desde el detalle.';

  static String leftTitle(String first, String group) =>
      '${_with(first, _someone)} salió de $group';
  static const String leftBody = 'Ya no hace parte del grupo.';

  static String approvedTitle(String group) => 'Ya eres parte de $group';
  static String approvedBody(String adminFirst) =>
      '${_with(adminFirst, 'Un admin')} aprobó tu solicitud.';

  static String removedYouTitle(String group) => 'Te eliminaron de $group';
  static String removedYouBody(String adminFirst) =>
      '${_with(adminFirst, 'Un admin')} te sacó del grupo. Puedes volver a pedir entrar con el código.';

  static String removedTitle(String first, String group) =>
      '${_with(first, _someone)} ya no está en $group';
  static String removedBody(String adminFirst, String memberFirst) =>
      '${_with(adminFirst, 'Un admin')} eliminó a ${_with(memberFirst, 'esta persona')} del grupo.';
}
