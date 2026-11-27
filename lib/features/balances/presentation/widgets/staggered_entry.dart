import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../balances_metrics.dart';

/// Fades its [child] in while it rises [offset] dp, after a delay that
/// grows with [index] (cascade of a list, up to
/// [BalancesMetrics.staggerMax] rows). Only plays when first built. With
/// `MediaQuery.disableAnimations` it is a plain 150 ms fade.
class StaggeredEntry extends StatefulWidget {
  const StaggeredEntry({
    super.key,
    required this.index,
    required this.child,
    this.duration = BalancesMetrics.rowEntry,
    this.stagger = BalancesMetrics.rowStagger,
    this.offset = BalancesMetrics.rowEntryOffset,
    this.delay = Duration.zero,
  });

  final int index;
  final Widget child;
  final Duration duration;
  final Duration stagger;
  final double offset;

  /// Extra delay before the cascade.
  final Duration delay;

  @override
  State<StaggeredEntry> createState() => _StaggeredEntryState();
}

class _StaggeredEntryState extends State<StaggeredEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Timer? _timer;
  bool _started = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_reduceMotion) {
      _controller.duration = BalancesMetrics.reducedFade;
      _controller.forward();
      return;
    }
    final steps = widget.index.clamp(0, BalancesMetrics.staggerMax);
    final wait = widget.delay + widget.stagger * steps;
    if (wait == Duration.zero) {
      _controller.forward();
    } else {
      _timer = Timer(wait, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: _reduceMotion
          ? widget.child
          : AnimatedBuilder(
              animation: _curved,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, widget.offset * (1 - _curved.value)),
                child: child,
              ),
              child: widget.child,
            ),
    );
  }
}
