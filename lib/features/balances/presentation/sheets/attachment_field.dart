import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/dashed_rounded_border.dart';
import '../../data/balances_providers.dart';
import '../../data/receipt_picker.dart';
import '../attachment_viewer_screen.dart';
import '../balances_metrics.dart';
import '../balances_strings.dart';
import '../balances_text_styles.dart';
import 'movement_failure_message.dart';

/// Hero tag of the image being attached (not saved yet).
const String pendingAttachmentTag = 'adjunto-nuevo';

/// The optional image of a payment or a debt.
///
/// Without one: a dashed 56 dp button ("Adjuntar imagen") that asks for the
/// camera or the gallery. With one: a 64 dp row with its thumbnail, name and
/// size ("toca para ver" opens it) and an × to remove it. Switching between
/// them cross-fades (150 ms) while the height animates (200 ms).
class AttachmentField extends ConsumerStatefulWidget {
  const AttachmentField({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
  });

  final PickedReceipt? value;
  final ValueChanged<PickedReceipt?> onChanged;
  final bool enabled;

  @override
  ConsumerState<AttachmentField> createState() => _AttachmentFieldState();
}

class _AttachmentFieldState extends ConsumerState<AttachmentField> {
  String? _error;

  Future<void> _pick() async {
    final source = await _showSourceSheet(context);
    if (source == null || !mounted) return;
    try {
      final picked = await ref.read(receiptPickerProvider).pick(source);
      if (!mounted) return;
      setState(() => _error = null);
      if (picked != null) widget.onChanged(picked);
    } catch (error) {
      if (mounted) setState(() => _error = movementFailureMessage(error));
    }
  }

  static String _size(int bytes) {
    const kb = 1024;
    if (bytes < kb * kb) return '${(bytes / kb).round()} KB';
    return '${(bytes / (kb * kb)).toStringAsFixed(1).replaceAll('.', ',')} MB';
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = BalancesTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final value = widget.value;
    final error = _error;

    final Widget content;
    if (value == null) {
      content = Semantics(
        key: const ValueKey('empty'),
        button: true,
        enabled: widget.enabled,
        child: InkWell(
          onTap: widget.enabled ? _pick : null,
          borderRadius: BorderRadius.circular(tokens.radiusInput),
          child: CustomPaint(
            painter: DashedRoundedBorderPainter(
              color: tokens.outlineMuted,
              radius: tokens.radiusInput,
              strokeWidth: BalancesMetrics.focusBorder,
              dash: BalancesMetrics.attachDash,
              gap: BalancesMetrics.attachGap,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: BalancesMetrics.attachMinHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: tokens.space2,
                  vertical: tokens.space1,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: BalancesMetrics.attachIcon,
                      color: tokens.textPrimary,
                    ),
                    const SizedBox(width: BalancesMetrics.rowGap),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(BalancesStrings.attach, style: styles.rowTitle),
                          Text(
                            BalancesStrings.attachHint,
                            style: styles.caption,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    } else {
      final thumb = ClipRRect(
        borderRadius: BorderRadius.circular(BalancesMetrics.thumbRadius),
        child: Image.file(
          File(value.path),
          width: BalancesMetrics.thumb,
          height: BalancesMetrics.thumb,
          fit: BoxFit.cover,
          errorBuilder: (context, _, _) => Container(
            width: BalancesMetrics.thumb,
            height: BalancesMetrics.thumb,
            color: tokens.border,
          ),
        ),
      );
      content = Material(
        key: ValueKey(value.path),
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radiusInput),
        clipBehavior: Clip.antiAlias,
        child: SizedBox(
          height: BalancesMetrics.attachedHeight,
          child: Row(
            children: [
              Expanded(
                child: Semantics(
                  button: true,
                  label: BalancesStrings.attachmentLabel,
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: () => context.push(
                      AppRoutes.attachment,
                      extra: AttachmentViewerArgs.file(
                        filePath: value.path,
                        heroTag: pendingAttachmentTag,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.only(left: tokens.space1),
                      child: Row(
                        children: [
                          TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: reduceMotion
                                  ? 1
                                  : BalancesMetrics.attachEntryScale,
                              end: 1,
                            ),
                            duration: BalancesMetrics.attachResize,
                            curve: Curves.easeOutCubic,
                            builder: (context, scale, child) =>
                                Transform.scale(scale: scale, child: child),
                            child: HeroMode(
                              enabled: !reduceMotion,
                              child: Hero(
                                tag: pendingAttachmentTag,
                                child: thumb,
                              ),
                            ),
                          ),
                          const SizedBox(width: BalancesMetrics.rowGap),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  value.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.rowTitle,
                                ),
                                Text(
                                  BalancesStrings.attachmentInfo(
                                    _size(value.bytes),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: styles.caption,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: BalancesStrings.removeAttachment,
                constraints: const BoxConstraints.tightFor(
                  width: BalancesMetrics.touchTarget,
                  height: BalancesMetrics.touchTarget,
                ),
                color: tokens.textSecondary,
                onPressed: widget.enabled ? () => widget.onChanged(null) : null,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSize(
          duration: reduceMotion
              ? BalancesMetrics.reducedFade
              : BalancesMetrics.attachResize,
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: AnimatedSwitcher(
            duration: reduceMotion
                ? BalancesMetrics.reducedFade
                : BalancesMetrics.attachSwap,
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            child: content,
          ),
        ),
        if (error != null) ...[
          SizedBox(height: tokens.space1),
          Semantics(
            liveRegion: true,
            child: Text(
              error,
              style: styles.body.copyWith(color: tokens.negative),
            ),
          ),
        ],
      ],
    );
  }
}

/// "Tomar foto" / "Elegir de la galería"; `null` when dismissed.
Future<ReceiptSource?> _showSourceSheet(BuildContext context) {
  final tokens = context.tokens;
  return showModalBottomSheet<ReceiptSource>(
    context: context,
    useRootNavigator: true,
    backgroundColor: tokens.surface,
    showDragHandle: true,
    builder: (context) {
      Widget option(ReceiptSource source, IconData icon, String label) =>
          ListTile(
            leading: Icon(icon, color: tokens.textPrimary),
            title: Text(label),
            onTap: () => Navigator.pop(context, source),
          );
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: tokens.space1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option(
                ReceiptSource.camera,
                Icons.photo_camera_outlined,
                BalancesStrings.takePhoto,
              ),
              option(
                ReceiptSource.gallery,
                Icons.photo_library_outlined,
                BalancesStrings.fromGallery,
              ),
            ],
          ),
        ),
      );
    },
  );
}
