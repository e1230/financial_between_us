import '../../../core/router/app_router.dart';
import '../../payment_accounts/domain/payment_account_rules.dart';
import '../domain/push_message.dart';
import 'notification_strings.dart';

/// Android channel a notification goes to.
enum NotificationChannelKind { movements, groups }

/// What a [PushMessage] looks like on the device and where it leads.
final class NotificationContent {
  const NotificationContent({
    required this.id,
    required this.title,
    required this.body,
    required this.channel,
    required this.route,
    this.showsAnswerActions = false,
  });

  /// Android notification id (stable for the same movement or member).
  final int id;
  final String title;
  final String body;
  final NotificationChannelKind channel;

  /// Where tapping it goes.
  final String route;

  /// "Confirmar" and "Rechazar".
  final bool showsAnswerActions;

  factory NotificationContent.of(PushMessage message) => switch (message) {
    MovementPush() => _movement(message),
    MemberPush() => _member(message),
  };

  static String _first(String name) => PaymentAccountRules.firstName(name);

  static NotificationContent _movement(MovementPush m) {
    final actor = _first(m.actorName);
    final (title, body) = switch (m.kind) {
      MovementPushKind.created => (
        m.isPayment
            ? (m.actorIsDebtor
                  ? NotificationStrings.paidYou(actor)
                  : NotificationStrings.registeredYourPayment(actor))
            : (m.actorIsDebtor
                  ? NotificationStrings.owesYou(actor)
                  : NotificationStrings.youOwe(actor)),
        '${NotificationStrings.newMovementBody(amount: m.amount, concept: m.concept, group: m.groupName)}\n'
            '${NotificationStrings.appliedHint}',
      ),
      MovementPushKind.rejected => (
        m.isPayment
            ? NotificationStrings.rejectedPayment(actor)
            : NotificationStrings.rejectedDebt(actor),
        NotificationStrings.rejectedBody(
          amount: m.amount,
          group: m.groupName,
          reason: m.rejectReason,
        ),
      ),
      MovementPushKind.deleted => (
        m.isPayment
            ? NotificationStrings.deletedPayment(actor)
            : NotificationStrings.deletedDebt(actor),
        NotificationStrings.deletedBody(amount: m.amount, group: m.groupName),
      ),
    };
    return NotificationContent(
      id: notificationIdOf(m.key),
      title: title,
      body: body,
      channel: NotificationChannelKind.movements,
      route: routeOf(m),
      showsAnswerActions: m.canAnswer,
    );
  }

  static NotificationContent _member(MemberPush m) {
    final actor = _first(m.actorName);
    final member = _first(m.memberName);
    final group = m.groupName;
    final (title, body) = switch (m.kind) {
      MemberPushKind.joined => (
        NotificationStrings.newMemberTitle(group),
        NotificationStrings.joinedBody(member),
      ),
      MemberPushKind.approved when m.isAboutRecipient => (
        NotificationStrings.approvedTitle(group),
        NotificationStrings.approvedBody(actor),
      ),
      MemberPushKind.approved => (
        NotificationStrings.newMemberTitle(group),
        NotificationStrings.joinedBody(member),
      ),
      MemberPushKind.requested => (
        NotificationStrings.requestTitle(group),
        NotificationStrings.requestBody(member),
      ),
      MemberPushKind.left => (
        NotificationStrings.leftTitle(member, group),
        NotificationStrings.leftBody,
      ),
      MemberPushKind.removed when m.isAboutRecipient => (
        NotificationStrings.removedYouTitle(group),
        NotificationStrings.removedYouBody(actor),
      ),
      MemberPushKind.removed => (
        NotificationStrings.removedTitle(member, group),
        NotificationStrings.removedBody(actor, member),
      ),
    };
    return NotificationContent(
      id: notificationIdOf(m.key),
      title: title,
      body: body,
      channel: NotificationChannelKind.groups,
      route: routeOf(m),
    );
  }

  /// Where [message] leads; with [reject], straight to rejecting the
  /// movement ("Rechazar").
  static String routeOf(PushMessage message, {bool reject = false}) =>
      switch (message) {
        MovementPush(:final actorUid, :final groupId, :final movementId) =>
          AppRoutes.personBalanceFor(
            actorUid,
            groupId,
            movementId: movementId,
            reject: reject,
          ),
        MemberPush(kind: MemberPushKind.removed, isAboutRecipient: true) =>
          AppRoutes.home,
        MemberPush(:final groupId) => AppRoutes.groupDetailFor(groupId),
      };
}

/// A positive 31-bit FNV-1a hash of [key]: the same in every isolate and
/// launch, unlike `String.hashCode`.
int notificationIdOf(String key) {
  var hash = 0x811c9dc5;
  for (final unit in key.codeUnits) {
    hash ^= unit;
    hash = (hash * 0x01000193) & 0xffffffff;
  }
  return hash & 0x7fffffff;
}
