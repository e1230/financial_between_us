import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../domain/payment_account.dart';
import '../payment_accounts_metrics.dart';
import 'payment_account_row.dart';

/// The accounts in one rounded card, with inset dividers between rows.
///
/// Rows enter in a cascade (fade + 8 dp rise, 240 ms, 40 ms apart, up to 8
/// staggered rows). A row that disappears (deleted) fades out and collapses
/// in 250 ms while the ones below move up. With
/// `MediaQuery.disableAnimations` both are plain 150 ms fades.
class AccountsCard extends StatefulWidget {
  const AccountsCard({
    super.key,
    required this.accounts,
    required this.onOpen,
    required this.onCopy,
  });

  final List<PaymentAccount> accounts;
  final ValueChanged<PaymentAccount> onOpen;
  final ValueChanged<PaymentAccount> onCopy;

  @override
  State<AccountsCard> createState() => _AccountsCardState();
}

class _Slot {
  _Slot(this.account, {this.leaving = false});

  final PaymentAccount account;
  final bool leaving;
}

class _AccountsCardState extends State<AccountsCard> {
  late List<_Slot> _slots = [for (final a in widget.accounts) _Slot(a)];

  /// Only the first build cascades; later rows just fade in.
  bool _initial = true;

  @override
  void didUpdateWidget(AccountsCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    _initial = false;
    _slots = _merge(_slots, widget.accounts);
  }

  /// [next] in order, keeping the rows that left at their old place (as
  /// leaving) until their exit animation ends.
  static List<_Slot> _merge(List<_Slot> previous, List<PaymentAccount> next) {
    final nextIds = {for (final a in next) a.id};
    final result = <_Slot>[];
    var i = 0;
    for (final slot in previous) {
      if (nextIds.contains(slot.account.id)) {
        while (i < next.length) {
          final account = next[i++];
          result.add(_Slot(account));
          if (account.id == slot.account.id) break;
        }
      } else {
        result.add(_Slot(slot.account, leaving: true));
      }
    }
    for (; i < next.length; i++) {
      result.add(_Slot(next[i]));
    }
    return result;
  }

  void _drop(String id) {
    if (!mounted) return;
    setState(() {
      _slots = [
        for (final s in _slots)
          if (!(s.leaving && s.account.id == id)) s,
      ];
    });
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(tokens.radiusCard),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (index, slot) in _slots.indexed)
            _RowSlot(
              key: ValueKey(slot.account.id),
              leaving: slot.leaving,
              delay: _initial && index < PaymentAccountsMetrics.maxStaggeredRows
                  ? PaymentAccountsMetrics.rowStagger * index
                  : Duration.zero,
              onGone: () => _drop(slot.account.id),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (index > 0)
                    Divider(
                      height: 1,
                      thickness: 1,
                      indent: PaymentAccountsMetrics.dividerInset,
                      color: tokens.border,
                    ),
                  PaymentAccountRow(
                    account: slot.account,
                    onOpen: () => widget.onOpen(slot.account),
                    onCopy: () => widget.onCopy(slot.account),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Entry and exit animation of one row.
class _RowSlot extends StatefulWidget {
  const _RowSlot({
    super.key,
    required this.leaving,
    required this.delay,
    required this.onGone,
    required this.child,
  });

  final bool leaving;
  final Duration delay;
  final VoidCallback onGone;
  final Widget child;

  @override
  State<_RowSlot> createState() => _RowSlotState();
}

class _RowSlotState extends State<_RowSlot> with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    vsync: this,
    duration: PaymentAccountsMetrics.rowEntry,
  );
  late final AnimationController _exit = AnimationController(
    vsync: this,
    duration: PaymentAccountsMetrics.rowExit,
  );
  bool _started = false;
  bool _reduceMotion = false;

  late final CurvedAnimation _exitCurve = CurvedAnimation(
    parent: _exit,
    curve: Curves.easeInOut,
  );

  /// Set on the first `didChangeDependencies`: the cascade delay is the
  /// first part of [_entry].
  late final CurvedAnimation _entryCurve;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _exit.duration = PaymentAccountsMetrics.reducedFade;
    }
    if (_started) return;
    _started = true;
    // The cascade delay is the first part of the entry animation (no
    // timers to cancel).
    final delay = _reduceMotion ? Duration.zero : widget.delay;
    final run = _reduceMotion
        ? PaymentAccountsMetrics.reducedFade
        : PaymentAccountsMetrics.rowEntry;
    final total = delay + run;
    _entry.duration = total;
    _entryCurve = CurvedAnimation(
      parent: _entry,
      curve: Interval(
        delay.inMicroseconds / total.inMicroseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
    _entry.forward();
    if (widget.leaving) _leave();
  }

  @override
  void didUpdateWidget(_RowSlot oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.leaving && !oldWidget.leaving) _leave();
  }

  Future<void> _leave() async {
    await _exit.forward();
    if (mounted) widget.onGone();
  }

  @override
  void dispose() {
    if (_started) _entryCurve.dispose();
    _exitCurve.dispose();
    _entry.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = _entryCurve;
    final exit = _exitCurve;
    Widget child = FadeTransition(
      opacity: entry,
      child: _reduceMotion
          ? widget.child
          : AnimatedBuilder(
              animation: entry,
              builder: (context, child) => Transform.translate(
                offset: Offset(
                  0,
                  PaymentAccountsMetrics.rowEntryOffset * (1 - entry.value),
                ),
                child: child,
              ),
              child: widget.child,
            ),
    );
    child = FadeTransition(
      opacity: ReverseAnimation(exit),
      child: _reduceMotion
          ? child
          : SizeTransition(
              sizeFactor: ReverseAnimation(exit),
              alignment: Alignment.topCenter,
              child: child,
            ),
    );
    // A leaving row ignores taps.
    return IgnorePointer(ignoring: widget.leaving, child: child);
  }
}
