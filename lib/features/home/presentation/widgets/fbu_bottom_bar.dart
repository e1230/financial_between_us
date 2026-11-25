import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../home_metrics.dart';
import '../home_strings.dart';
import 'add_button.dart';
import 'bottom_tab.dart';

/// Tabs of the shell, in branch order.
enum ShellTab { home, events, balances, profile }

/// Bottom bar of the shell: Inicio, Eventos, +, Saldos and Perfil. The
/// gesture bar stays inside it (edge-to-edge). Without an active group,
/// Eventos, + and Saldos are disabled.
class FbuBottomBar extends StatelessWidget {
  const FbuBottomBar({
    super.key,
    required this.current,
    required this.hasGroup,
    required this.onSelect,
  });

  final ShellTab current;
  final bool hasGroup;
  final ValueChanged<ShellTab> onSelect;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final bottom = MediaQuery.paddingOf(context).bottom;

    Widget tab(
      ShellTab tab,
      IconData icon,
      String label, {
      bool needsGroup = false,
    }) => BottomTab(
      icon: icon,
      label: label,
      selected: tab == current,
      onTap: needsGroup && !hasGroup ? null : () => onSelect(tab),
    );

    // The + rises above the bar. It lives in a taller, transparent box so
    // its whole circle receives taps; the empty corners let taps through.
    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: SizedBox(
        height: HomeMetrics.addButtonRaise + HomeMetrics.barHeight + bottom,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: HomeMetrics.barHeight + bottom,
              child: Container(
                padding: EdgeInsets.only(
                  left: HomeMetrics.barPaddingH,
                  right: HomeMetrics.barPaddingH,
                  bottom: bottom,
                ),
                decoration: BoxDecoration(
                  color: tokens.surface,
                  border: Border(top: BorderSide(color: tokens.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    tab(
                      ShellTab.home,
                      Icons.home_outlined,
                      HomeStrings.tabHome,
                    ),
                    tab(
                      ShellTab.events,
                      Icons.calendar_today_outlined,
                      HomeStrings.tabEvents,
                      needsGroup: true,
                    ),
                    const SizedBox(width: HomeMetrics.addButtonSize),
                    tab(
                      ShellTab.balances,
                      Icons.balance_outlined,
                      HomeStrings.tabBalances,
                      needsGroup: true,
                    ),
                    tab(
                      ShellTab.profile,
                      Icons.person_outline,
                      HomeStrings.tabProfile,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(child: AddButton(enabled: hasGroup)),
            ),
          ],
        ),
      ),
    );
  }
}
