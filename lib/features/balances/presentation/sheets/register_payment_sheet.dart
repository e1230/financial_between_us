import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../payment_accounts/data/payment_accounts_providers.dart';
import '../../../payment_accounts/presentation/widgets/accounts_skeleton.dart';
import '../../data/balances_providers.dart';
import '../../data/receipt_picker.dart';
import '../../domain/movement_validators.dart';
import '../../domain/pair_ledger.dart';
import '../../domain/payment_allocation.dart';
import '../balances_strings.dart';
import '../widgets/pill_choice.dart';
import '../widgets/section_label.dart';
import 'account_choice.dart';
import 'amount_field.dart';
import 'applies_to_box.dart';
import 'attachment_field.dart';
import 'balances_sheet.dart';
import 'movement_failure_message.dart';

/// A payment saved from the sheet.
final class RegisteredPayment {
  const RegisteredPayment({required this.amount, required this.ids});

  final int amount;

  /// One movement per group.
  final List<String> ids;
}

/// Opens "Registrar pago" between [me] and [otherUid]. When [theyPayMe],
/// the other person pays what they owe the user; otherwise the user pays
/// them. [pendings] are the items the payer owes, oldest first.
Future<RegisteredPayment?> showRegisterPaymentSheet(
  BuildContext context, {
  required String me,
  required String otherUid,
  required String otherFirstName,
  required bool theyPayMe,
  required List<PendingItem> pendings,
}) => showBalancesSheet<RegisteredPayment>(
  context: context,
  builder: (_) => RegisterPaymentSheet(
    me: me,
    otherUid: otherUid,
    otherFirstName: otherFirstName,
    theyPayMe: theyPayMe,
    pendings: pendings,
  ),
);

/// "Registrar pago": the amount (with "Todo" / "Otro monto"), which pending
/// items it settles, the account it went to, an optional image and the
/// button. It is applied right away; the other person can reject it.
class RegisterPaymentSheet extends ConsumerStatefulWidget {
  const RegisterPaymentSheet({
    super.key,
    required this.me,
    required this.otherUid,
    required this.otherFirstName,
    required this.theyPayMe,
    required this.pendings,
  });

  final String me;
  final String otherUid;
  final String otherFirstName;
  final bool theyPayMe;
  final List<PendingItem> pendings;

  @override
  ConsumerState<RegisterPaymentSheet> createState() =>
      _RegisterPaymentSheetState();
}

class _RegisterPaymentSheetState extends ConsumerState<RegisterPaymentSheet> {
  late final Set<String> _included = {for (final p in widget.pendings) p.id};
  late final TextEditingController _amount = TextEditingController(
    text: PesosInputFormatter.format(_max),
  );
  final FocusNode _amountFocus = FocusNode();
  late int? _value = _max;
  bool _showErrors = false;
  String? _accountKey;
  PickedReceipt? _receipt;
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _amount.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  /// What the payer still owes on the items taking part.
  int get _max => pendingTotal(widget.pendings, _included);

  List<Allocation> get _allocations => allocatePayment(
    amount: _value ?? 0,
    pendings: widget.pendings,
    selectedIds: _included,
  );

  String? get _amountError {
    final failure = MovementValidators.paymentAmount(_value, pending: _max);
    return switch (failure) {
      MovementAmountRequired() => BalancesStrings.amountRequired,
      MovementAmountTooHigh(:final max) => BalancesStrings.amountTooHigh(max),
      _ => null,
    };
  }

  void _setAmount(int? value) {
    _amount.text = PesosInputFormatter.format(value);
    setState(() => _value = value);
  }

  void _otherAmount() {
    _amountFocus.requestFocus();
    _amount.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _amount.text.length,
    );
  }

  /// Unchecks a covered item, or checks one the amount does not reach yet
  /// (raising the amount to cover it).
  void _toggle(PendingItem item) {
    final covered = _allocations.any((a) => a.item.id == item.id);
    if (covered) {
      setState(() => _included.remove(item.id));
      if ((_value ?? 0) > _max) _setAmount(_max);
      return;
    }
    setState(() => _included.add(item.id));
    final raised = (_value ?? 0) + item.remaining;
    _setAmount(raised > _max ? _max : raised);
  }

  Future<void> _save(AccountOption? account) async {
    setState(() => _showErrors = true);
    final value = _value;
    if (_amountError != null || value == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final payer = widget.theyPayMe ? widget.otherUid : widget.me;
    final receiver = widget.theyPayMe ? widget.me : widget.otherUid;
    try {
      final ids = await ref
          .read(movementActionsProvider)
          .registerPayment(
            me: widget.me,
            payerUid: payer,
            receiverUid: receiver,
            allocations: _allocations,
            date: DateTime.now(),
            account: account?.snapshot,
            receipt: _receipt,
          );
      // TODO: FCM — tell the other person ("{name} registró que te pagó").
      if (mounted) {
        Navigator.of(context).pop(RegisteredPayment(amount: value, ids: ids));
      }
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
    final first = widget.otherFirstName;
    final accountsAsync = widget.theyPayMe
        ? ref.watch(myPaymentAccountsProvider)
        : ref.watch(paymentAccountsOfProvider(widget.otherUid));
    final options = accountsAsync.hasValue
        ? AccountOption.listOf(accountsAsync.value!)
        : accountsAsync.hasError
        ? const [AccountOption.cash]
        : null;
    final selected = options?.firstWhere(
      (o) => o.key == _accountKey,
      orElse: () => options.first,
    );
    final error = _showErrors || (_value ?? 0) > _max ? _amountError : null;
    final valid = _amountError == null;
    final value = _value ?? 0;

    final Widget accounts = options == null
        ? const AccountsSkeleton()
        : widget.theyPayMe
        ? AccountChips(
            options: options,
            selectedKey: selected?.key,
            onSelect: (o) => setState(() => _accountKey = o.key),
          )
        : AccountRadioList(
            options: options,
            selectedKey: selected?.key,
            onSelect: (o) => setState(() => _accountKey = o.key),
          );

    return BalancesSheetFrame(
      title: BalancesStrings.registerPayment,
      subtitle: widget.theyPayMe
          ? BalancesStrings.theyPaidYou(first)
          : BalancesStrings.youPaidThem(first),
      footer: FbuPrimaryButton(
        onPressed: valid && !_busy ? () => _save(selected) : null,
        isLoading: _busy,
        loadingSemanticsLabel: BalancesStrings.saving,
        child: Text(
          BalancesStrings.registerPaymentAmount(value),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      children: [
        AmountField(
          controller: _amount,
          focusNode: _amountFocus,
          errorText: error,
          onChanged: (v) => setState(() => _value = v),
        ),
        SizedBox(height: tokens.space1),
        Wrap(
          spacing: tokens.space1,
          children: [
            PillChoice(
              label: BalancesStrings.all(_max),
              selected: value == _max,
              onTap: _busy ? null : () => _setAmount(_max),
            ),
            PillChoice(
              label: BalancesStrings.otherAmount,
              selected: value != _max,
              onTap: _busy ? null : _otherAmount,
            ),
          ],
        ),
        // DECISIÓN: when the user pays, the payment is split oldest first
        // without showing the list, as the spec suggests.
        if (widget.theyPayMe && widget.pendings.isNotEmpty) ...[
          SizedBox(height: tokens.space3),
          const SectionLabel(BalancesStrings.appliesTo),
          AppliesToBox(
            pendings: widget.pendings,
            allocations: _allocations,
            onToggle: _busy ? (_) {} : _toggle,
          ),
        ],
        SizedBox(height: tokens.space3),
        SectionLabel(
          widget.theyPayMe
              ? BalancesStrings.whichOfYours
              : BalancesStrings.whichOfTheirs,
        ),
        accounts,
        SizedBox(height: tokens.space3),
        AttachmentField(
          value: _receipt,
          enabled: !_busy,
          onChanged: (r) => setState(() => _receipt = r),
        ),
        if (!widget.theyPayMe) ...[
          SizedBox(height: tokens.space2),
          SheetNotice(BalancesStrings.paymentNotice(first)),
        ],
        if (_error case final message?) ...[
          SizedBox(height: tokens.space2),
          SheetError(message),
        ],
      ],
    );
  }
}
