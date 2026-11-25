import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/accent_color.dart';
import '../profile_metrics.dart';
import '../profile_strings.dart';
import 'shade_area.dart';

/// Color of the user: quick picks plus a free picker (hue + shade) limited
/// to colors readable with `#111111` text.
class AccentColorPicker extends StatefulWidget {
  const AccentColorPicker({
    super.key,
    required this.colorValue,
    required this.onChanged,
    this.enabled = true,
  });

  /// Selected color, opaque ARGB.
  final int colorValue;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  State<AccentColorPicker> createState() => _AccentColorPickerState();
}

class _AccentColorPickerState extends State<AccentColorPicker> {
  late bool _customOpen = !_isPreset(widget.colorValue);
  late HSVColor _custom = HSVColor.fromColor(Color(widget.colorValue));

  static bool _isPreset(int value) => AccentColor.presets.contains(value);

  void _selectPreset(int value) {
    setState(() => _customOpen = false);
    widget.onChanged(value);
  }

  void _toggleCustom() {
    setState(() => _customOpen = !_customOpen);
    if (_customOpen) widget.onChanged(_custom.toColor().toARGB32());
  }

  void _selectCustom(HSVColor color) {
    setState(() => _custom = color);
    widget.onChanged(color.toColor().toARGB32());
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final customSelected = _customOpen || !_isPreset(widget.colorValue);

    return IgnorePointer(
      ignoring: !widget.enabled,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: ProfileMetrics.swatchGap,
            runSpacing: ProfileMetrics.swatchGap,
            children: [
              for (final (i, value) in AccentColor.presets.indexed)
                _Swatch(
                  label: ProfileStrings.presetNames[i],
                  selected: !customSelected && widget.colorValue == value,
                  fill: Color(value),
                  onTap: () => _selectPreset(value),
                ),
              _Swatch(
                label: ProfileStrings.customColor,
                selected: customSelected,
                fill: customSelected ? _custom.toColor() : null,
                onTap: _toggleCustom,
              ),
            ],
          ),
          AnimatedSize(
            duration: reduceMotion ? Duration.zero : tokens.motionShort,
            alignment: Alignment.topCenter,
            child: _customOpen
                ? Padding(
                    padding: EdgeInsets.only(top: tokens.space2),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ShadeArea(color: _custom, onChanged: _selectCustom),
                        SizedBox(height: tokens.space1),
                        HueBar(color: _custom, onChanged: _selectCustom),
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// One round swatch. Without [fill] it shows the hue wheel (custom color).
class _Swatch extends StatelessWidget {
  const _Swatch({
    required this.label,
    required this.selected,
    required this.onTap,
    this.fill,
  });

  final String label;
  final bool selected;
  final Color? fill;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final color = fill;
    const stops = ProfileMetrics.hueStops;
    return Semantics(
      button: true,
      selected: selected,
      label: selected ? ProfileStrings.selected(label) : label,
      child: ExcludeSemantics(
        child: Tooltip(
          message: label,
          child: InkResponse(
            onTap: onTap,
            radius: ProfileMetrics.swatchTouchTarget / 2,
            child: SizedBox.square(
              dimension: ProfileMetrics.swatchTouchTarget,
              child: Center(
                child: Container(
                  width: ProfileMetrics.swatchSize,
                  height: ProfileMetrics.swatchSize,
                  padding: const EdgeInsets.all(ProfileMetrics.swatchRingGap),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      width: ProfileMetrics.swatchRingWidth,
                      color: selected
                          ? tokens.textPrimary
                          : tokens.textPrimary.withValues(alpha: 0),
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      gradient: color != null
                          ? null
                          : SweepGradient(
                              colors: [
                                for (var i = 0; i < stops; i++)
                                  HSVColor.fromAHSV(
                                    1,
                                    i * 360 / (stops - 1) % 360,
                                    0.6,
                                    1,
                                  ).toColor(),
                              ],
                            ),
                    ),
                    child: selected && color != null
                        ? Icon(
                            Icons.check,
                            size: ProfileMetrics.swatchCheckSize,
                            color: tokens.onAccent,
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
