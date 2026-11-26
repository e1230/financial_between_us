import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../theme/app_tokens.dart';

/// Where a [FbuToast] shows up.
enum FbuToastPosition {
  /// Centered, 48 dp above the gesture bar (the default).
  bottom,

  /// 16 dp below the status bar, so it does not cover a bottom sheet.
  top,
}

/// Short confirmation pill ("Copiado", "Cuenta guardada"): light fill,
/// dark text and a check, in its own [OverlayEntry] (not a `SnackBar`, so
/// it keeps the pill shape and can sit above a bottom sheet).
///
/// Enters with a fade and an 8 dp rise (200 ms), stays [visibleFor] and
/// fades out (150 ms). A new toast replaces the one on screen. With
/// `MediaQuery.disableAnimations` it only fades, in 150 ms. Screen readers
/// announce it (live region).
abstract final class FbuToast {
  static const Duration visibleFor = Duration(milliseconds: 1500);
  static const Duration entryDuration = Duration(milliseconds: 200);
  static const Duration exitDuration = Duration(milliseconds: 150);
  static const double height = 44;
  static const double paddingStart = 14;
  static const double paddingEnd = 18;
  static const double iconSize = 20;
  static const double iconGap = 8;
  static const double bottomOffset = 48;
  static const double topOffset = 16;
  static const double entryOffset = 8;

  static OverlayEntry? _entry;

  /// Shows [message] over the whole app (the root overlay).
  static void show(
    BuildContext context,
    String message, {
    FbuToastPosition position = FbuToastPosition.bottom,
  }) {
    final overlay = Overlay.of(context, rootOverlay: true);
    dismiss();
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _Toast(
        message: message,
        position: position,
        onDone: () {
          if (identical(_entry, entry)) {
            _entry = null;
          }
          entry.remove();
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }

  /// Removes the toast on screen right away, if any.
  static void dismiss() {
    final entry = _entry;
    _entry = null;
    if (entry != null && entry.mounted) entry.remove();
  }
}

class _Toast extends StatefulWidget {
  const _Toast({
    required this.message,
    required this.position,
    required this.onDone,
  });

  final String message;
  final FbuToastPosition position;
  final VoidCallback onDone;

  @override
  State<_Toast> createState() => _ToastState();
}

class _ToastState extends State<_Toast> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: FbuToast.entryDuration,
    reverseDuration: FbuToast.exitDuration,
  );
  late final CurvedAnimation _curved = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );
  Timer? _timer;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.duration = FbuToast.exitDuration;
    }
    _controller.forward();
    _timer = Timer(FbuToast.visibleFor, _hide);
  }

  Future<void> _hide() async {
    if (!mounted) return;
    await _controller.reverse();
    if (mounted) widget.onDone();
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
    final tokens = context.tokens;
    final padding = MediaQuery.paddingOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final atTop = widget.position == FbuToastPosition.top;
    final curved = _curved;
    final style = Theme.of(context).textTheme.labelMedium!
        .copyWith(color: tokens.background);

    final pill = Container(
      height: FbuToast.height,
      padding: const EdgeInsetsDirectional.only(
        start: FbuToast.paddingStart,
        end: FbuToast.paddingEnd,
      ),
      decoration: ShapeDecoration(
        color: tokens.textPrimary,
        shape: const StadiumBorder(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: FbuToast.iconSize, color: tokens.background),
          const SizedBox(width: FbuToast.iconGap),
          Flexible(
            child: Text(
              widget.message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ],
      ),
    );

    return Positioned(
      left: tokens.space2,
      right: tokens.space2,
      top: atTop ? padding.top + FbuToast.topOffset : null,
      bottom: atTop ? null : padding.bottom + FbuToast.bottomOffset,
      child: IgnorePointer(
        child: Center(
          child: Semantics(
            liveRegion: true,
            container: true,
            label: widget.message,
            child: ExcludeSemantics(
              child: FadeTransition(
                opacity: curved,
                child: AnimatedBuilder(
                  animation: curved,
                  builder: (context, child) => Transform.translate(
                    offset: Offset(
                      0,
                      reduceMotion
                          ? 0
                          : FbuToast.entryOffset *
                                (1 - curved.value) *
                                (atTop ? -1 : 1),
                    ),
                    child: child,
                  ),
                  child: Material(type: MaterialType.transparency, child: pill),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
