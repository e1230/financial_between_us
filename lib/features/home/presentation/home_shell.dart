import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../groups/data/groups_providers.dart';
import '../../notifications/presentation/notifications_providers.dart';
import 'widgets/fbu_bottom_bar.dart';

/// Shell of the signed-in app: the current tab (each keeps its state) over
/// the bottom bar.
///
/// System back: in another tab it returns to Inicio; in Inicio it closes
/// the app.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  void initState() {
    super.initState();
    // The first time someone reaches the Home: may we notify them?
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(notificationPermissionPromptProvider).askOnce().ignore();
      }
    });
  }

  void _go(ShellTab tab) => navigationShell.goBranch(
    tab.index,
    // Tapping the current tab again returns it to its first page.
    initialLocation: tab.index == navigationShell.currentIndex,
  );

  @override
  Widget build(BuildContext context) {
    final hasGroup = ref.watch(activeGroupProvider).value != null;
    final current = ShellTab.values[navigationShell.currentIndex];
    return BackButtonListener(
      onBackButtonPressed: () async {
        // Only when nothing (menu, dialog, popover) is on top of the shell.
        final isCurrent = ModalRoute.of(context)?.isCurrent ?? true;
        if (!isCurrent || current == ShellTab.home) return false;
        _go(ShellTab.home);
        return true;
      },
      child: Scaffold(
        extendBody: true,
        body: navigationShell,
        bottomNavigationBar: FbuBottomBar(
          current: current,
          hasGroup: hasGroup,
          onSelect: _go,
        ),
      ),
    );
  }
}
