import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../data/balances_providers.dart';
import '../../domain/group_event.dart';
import '../balances_format.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/movement_icon.dart';
import 'balances_sheet.dart';

/// What [showEventPicker] returns: an event, or none (a direct debt).
final class EventChoice {
  const EventChoice(this.event);

  /// `null` for "Sin evento · deuda directa".
  final GroupEvent? event;
}

/// Lets the user pick an event of [groupId] (newest first) or "Sin evento".
/// `null` when dismissed.
Future<EventChoice?> showEventPicker(
  BuildContext context, {
  required String groupId,
  required String? selectedId,
}) => showBalancesSheet<EventChoice>(
  context: context,
  builder: (_) => _EventPicker(groupId: groupId, selectedId: selectedId),
);

class _EventPicker extends ConsumerWidget {
  const _EventPicker({required this.groupId, required this.selectedId});

  final String groupId;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final events = ref.watch(groupEventsProvider(groupId)).value ?? const [];

    Widget option({
      required MovementIconKind icon,
      required String title,
      String? subtitle,
      required bool selected,
      required VoidCallback onTap,
    }) => Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: MovementIcon(icon),
        title: Text(title, style: styles.rowTitle),
        subtitle: subtitle == null
            ? null
            : Text(subtitle, style: styles.rowDetail),
        trailing: selected ? Icon(Icons.check, color: tokens.accent) : null,
        onTap: onTap,
      ),
    );

    return BalancesSheetFrame(
      title: BalancesStrings.chooseEvent,
      children: [
        option(
          icon: MovementIconKind.direct,
          title: BalancesStrings.noEvent,
          selected: selectedId == null,
          onTap: () => Navigator.of(context).pop(const EventChoice(null)),
        ),
        for (final event in events)
          option(
            icon: MovementIconKind.event,
            title: event.name,
            subtitle: BalancesDates.short(event.date),
            selected: event.id == selectedId,
            onTap: () => Navigator.of(context).pop(EventChoice(event)),
          ),
      ],
    );
  }
}
