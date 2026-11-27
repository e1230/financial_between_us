import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../auth/presentation/widgets/fbu_text_field.dart';
import '../../data/balances_providers.dart';
import '../../data/receipt_picker.dart';
import '../../domain/group_event.dart';
import '../../domain/movement_validators.dart';
import '../balances_format.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import '../widgets/pill_choice.dart';
import '../widgets/section_label.dart';
import 'amount_field.dart';
import 'attachment_field.dart';
import 'balances_sheet.dart';
import 'direction_toggle.dart';
import 'event_picker_sheet.dart';
import 'movement_failure_message.dart';

/// A group the debt can be registered in.
final class DebtGroupOption {
  const DebtGroupOption({required this.id, required this.name});

  final String id;
  final String name;
}

/// Opens "Registrar deuda" with [otherUid]. [groups] are the groups both
/// share (the first is the default). Completes with the new debt's id.
Future<String?> showRegisterDebtSheet(
  BuildContext context, {
  required String me,
  required String otherUid,
  required String otherFullName,
  required String otherFirstName,
  required List<DebtGroupOption> groups,
}) => showBalancesSheet<String>(
  context: context,
  builder: (_) => RegisterDebtSheet(
    me: me,
    otherUid: otherUid,
    otherFullName: otherFullName,
    otherFirstName: otherFirstName,
    groups: groups,
  ),
);

/// "Registrar deuda": who owes whom, the amount, the concept, an optional
/// event (without one it is a direct debt), the date and an optional image.
/// It adds to the balance right away; the other person can reject it.
class RegisterDebtSheet extends ConsumerStatefulWidget {
  const RegisterDebtSheet({
    super.key,
    required this.me,
    required this.otherUid,
    required this.otherFullName,
    required this.otherFirstName,
    required this.groups,
  });

  final String me;
  final String otherUid;
  final String otherFullName;
  final String otherFirstName;
  final List<DebtGroupOption> groups;

  @override
  ConsumerState<RegisterDebtSheet> createState() => _RegisterDebtSheetState();
}

class _RegisterDebtSheetState extends ConsumerState<RegisterDebtSheet> {
  final TextEditingController _amount = TextEditingController();
  final FocusNode _amountFocus = FocusNode();
  final TextEditingController _concept = TextEditingController();
  final FocusNode _conceptFocus = FocusNode();
  bool _theyOweMe = true;
  int? _value;
  late String _groupId = widget.groups.first.id;
  GroupEvent? _event;
  DateTime _date = DateTime.now();
  PickedReceipt? _receipt;
  bool _showErrors = false;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _amountFocus.dispose();
    _concept.dispose();
    _conceptFocus.dispose();
    super.dispose();
  }

  String? get _amountError => switch (MovementValidators.debtAmount(_value)) {
    MovementAmountRequired() => BalancesStrings.amountRequired,
    MovementAmountTooHigh(:final max) => BalancesStrings.amountTooHighDebt(max),
    _ => null,
  };

  String? get _conceptError =>
      switch (MovementValidators.concept(_concept.text)) {
        MovementConceptRequired() => BalancesStrings.conceptRequired,
        MovementConceptTooLong() => BalancesStrings.conceptTooLong,
        _ => null,
      };

  Future<void> _pickEvent() async {
    final choice = await showEventPicker(
      context,
      groupId: _groupId,
      selectedId: _event?.id,
    );
    if (choice != null && mounted) setState(() => _event = choice.event);
  }

  Future<void> _pickDate() async {
    final tokens = context.tokens;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: tokens.accent,
              onPrimary: tokens.onAccent,
              surface: tokens.surface,
              onSurface: tokens.textPrimary,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: tokens.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(tokens.radiusDialog),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    // DECISIÓN: the chosen day keeps the current time, so movements of the
    // same day keep the order in which they were registered.
    setState(
      () => _date = DateTime(
        picked.year,
        picked.month,
        picked.day,
        now.hour,
        now.minute,
        now.second,
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _showErrors = true);
    final value = _value;
    if (_amountError != null || _conceptError != null || value == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(movementActionsProvider)
          .registerDebt(
            me: widget.me,
            groupId: _groupId,
            debtorUid: _theyOweMe ? widget.otherUid : widget.me,
            creditorUid: _theyOweMe ? widget.me : widget.otherUid,
            amount: value,
            concept: _concept.text,
            date: _date,
            event: _event,
            receipt: _receipt,
          );
      // TODO: FCM — tell the other person ("{name} registró una deuda").
      if (mounted) Navigator.of(context).pop(id);
    } catch (error) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = movementFailureMessage(error);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final first = widget.otherFirstName;
    final now = DateTime.now();
    final isToday =
        _date.year == now.year &&
        _date.month == now.month &&
        _date.day == now.day;
    final dateText = isToday
        ? BalancesStrings.today(BalancesDates.short(_date))
        : BalancesDates.short(_date);

    Widget readOnlyField({
      required String label,
      required String value,
      required IconData icon,
      required VoidCallback onTap,
    }) => Semantics(
      button: true,
      label: '$label, $value',
      excludeSemantics: true,
      child: Material(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radiusInput),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: _busy ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: BalancesMetrics.fieldHeight,
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: tokens.space2,
                vertical: tokens.space1,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: styles.caption),
                        Text(
                          value,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: styles.rowTitle,
                        ),
                      ],
                    ),
                  ),
                  Icon(icon, color: tokens.textSecondary),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    return BalancesSheetFrame(
      title: BalancesStrings.registerDebt,
      subtitle: BalancesStrings.with_(widget.otherFullName),
      footer: FbuPrimaryButton(
        onPressed: _busy ? null : _save,
        isLoading: _busy,
        loadingSemanticsLabel: BalancesStrings.saving,
        child: const Text(BalancesStrings.registerDebt),
      ),
      children: [
        DirectionToggle(
          theyOweMeLabel: BalancesStrings.theyOweMe(first),
          theyOweMe: _theyOweMe,
          onChanged: _busy ? null : (v) => setState(() => _theyOweMe = v),
        ),
        SizedBox(height: tokens.space2),
        AmountField(
          controller: _amount,
          focusNode: _amountFocus,
          errorText: _showErrors ? _amountError : null,
          onChanged: (v) => setState(() => _value = v),
        ),
        SizedBox(height: tokens.space2),
        FbuTextField(
          controller: _concept,
          focusNode: _conceptFocus,
          label: BalancesStrings.concept,
          hint: BalancesStrings.conceptHint,
          enabled: !_busy,
          textCapitalization: TextCapitalization.sentences,
          textInputAction: TextInputAction.done,
          errorText: _showErrors ? _conceptError : null,
          onChanged: (_) => setState(() {}),
        ),
        if (widget.groups.length > 1) ...[
          SizedBox(height: tokens.space2),
          const SectionLabel(BalancesStrings.group),
          Wrap(
            spacing: tokens.space1,
            children: [
              for (final g in widget.groups)
                PillChoice(
                  label: g.name,
                  selected: g.id == _groupId,
                  onTap: _busy
                      ? null
                      : () => setState(() {
                          _groupId = g.id;
                          _event = null;
                        }),
                ),
            ],
          ),
        ],
        SizedBox(height: tokens.space2),
        readOnlyField(
          label: BalancesStrings.eventOptional,
          value: _event?.name ?? BalancesStrings.noEvent,
          icon: Icons.chevron_right,
          onTap: _pickEvent,
        ),
        SizedBox(height: tokens.space2),
        readOnlyField(
          label: BalancesStrings.date,
          value: dateText,
          icon: Icons.calendar_today_outlined,
          onTap: _pickDate,
        ),
        SizedBox(height: tokens.space2),
        AttachmentField(
          value: _receipt,
          enabled: !_busy,
          onChanged: (r) => setState(() => _receipt = r),
        ),
        SizedBox(height: tokens.space2),
        SheetNotice(BalancesStrings.debtNotice(first)),
        if (_error case final message?) ...[
          SizedBox(height: tokens.space2),
          SheetError(message),
        ],
      ],
    );
  }
}
