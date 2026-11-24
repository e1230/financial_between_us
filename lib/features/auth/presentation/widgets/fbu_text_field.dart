import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../auth_metrics.dart';
import '../auth_strings.dart';
import '../auth_text_styles.dart';

/// Filled text field of the auth forms: label inside, on top of the value.
///
/// The 1.5 dp border is transparent at rest, green with focus and red with
/// [errorText] (150 ms). [errorText] (or [helperText]) shows below the field
/// with a fade and a 4 dp drop. With [isPassword] the field gets an eye
/// button that shows or hides the text.
class FbuTextField extends StatefulWidget {
  const FbuTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.isPassword = false,
    this.enabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.autocorrect = true,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final bool isPassword;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final bool autocorrect;
  final TextCapitalization textCapitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<FbuTextField> createState() => _FbuTextFieldState();
}

class _FbuTextFieldState extends State<FbuTextField> {
  bool _obscured = true;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(FbuTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode.removeListener(_onFocusChanged);
      widget.focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onFocusChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = AuthTextStyles.of(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final fast = reduceMotion ? Duration.zero : tokens.motionFast;
    final hasError = widget.errorText != null;
    final focused = widget.focusNode.hasFocus;

    final accentColor = hasError
        ? tokens.negative
        : focused
        ? tokens.accent
        : null;
    final message = widget.errorText ?? widget.helperText;

    final field = AnimatedContainer(
      duration: fast,
      constraints: const BoxConstraints(minHeight: AuthMetrics.fieldHeight),
      padding: EdgeInsets.only(
        left: tokens.space2,
        right: widget.isPassword ? 0 : tokens.space2,
      ),
      decoration: BoxDecoration(
        color: tokens.surfaceVariant,
        borderRadius: BorderRadius.circular(tokens.radiusInput),
        border: Border.all(
          width: AuthMetrics.fieldBorderWidth,
          color: accentColor ?? tokens.surfaceVariant.withValues(alpha: 0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: AuthMetrics.fieldVerticalPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: fast,
                    style: styles.fieldLabel.copyWith(color: accentColor),
                    child: Text(widget.label),
                  ),
                  const SizedBox(height: AuthMetrics.fieldLabelGap),
                  TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    enabled: widget.enabled,
                    obscureText: widget.isPassword && _obscured,
                    enableSuggestions: !widget.isPassword && widget.autocorrect,
                    autocorrect: widget.autocorrect,
                    keyboardType: widget.isPassword
                        ? TextInputType.visiblePassword
                        : widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    textCapitalization: widget.textCapitalization,
                    autofillHints: widget.autofillHints,
                    inputFormatters: widget.inputFormatters,
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                    style: styles.fieldValue,
                    cursorColor: tokens.accent,
                    // Every border and the fill are set explicitly so the
                    // app-wide `inputDecorationTheme` does not leak in: the
                    // container above draws them.
                    decoration: InputDecoration(
                      hintText: widget.hint,
                      hintStyle: styles.fieldValue.copyWith(
                        color: tokens.textDisabled,
                      ),
                      isDense: true,
                      isCollapsed: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (widget.isPassword) _eyeButton(tokens, fast),
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          // Lets TalkBack read the error together with the field.
          hint: widget.errorText,
          child: GestureDetector(
            // The label area also focuses the field.
            onTap: widget.enabled ? widget.focusNode.requestFocus : null,
            child: field,
          ),
        ),
        _FieldMessage(
          message: message,
          isError: hasError,
          duration: reduceMotion ? Duration.zero : tokens.motionShort,
        ),
      ],
    );
  }

  Widget _eyeButton(AppTokens tokens, Duration fast) {
    final showing = !_obscured;
    return IconButton(
      onPressed: widget.enabled
          ? () => setState(() => _obscured = !_obscured)
          : null,
      tooltip: showing ? AuthStrings.hidePassword : AuthStrings.showPassword,
      constraints: const BoxConstraints.tightFor(
        width: AuthMetrics.touchTarget,
        height: AuthMetrics.touchTarget,
      ),
      padding: EdgeInsets.zero,
      icon: AnimatedSwitcher(
        duration: fast,
        child: Icon(
          showing ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          key: ValueKey(showing),
          size: AuthMetrics.eyeIconSize,
          color: showing ? tokens.accent : tokens.iconMuted,
        ),
      ),
    );
  }
}

/// Helper or error text below a field; enters with a fade and a 4 dp drop.
class _FieldMessage extends StatelessWidget {
  const _FieldMessage({
    required this.message,
    required this.isError,
    required this.duration,
  });

  final String? message;
  final bool isError;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final style = AuthTextStyles.of(context).helper;
    final text = message;
    return AnimatedSize(
      duration: duration,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: duration,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topLeft,
          children: [...previous, ?current],
        ),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: AnimatedBuilder(
            animation: animation,
            builder: (context, child) => Transform.translate(
              offset: Offset(
                0,
                -AuthMetrics.helperEntryOffset * (1 - animation.value),
              ),
              child: child,
            ),
            child: child,
          ),
        ),
        child: text == null
            ? const SizedBox(key: ValueKey(null), width: double.infinity)
            : Padding(
                key: ValueKey('$isError$text'),
                padding: EdgeInsets.only(
                  top: AuthMetrics.helperGap,
                  left: tokens.space2,
                ),
                child: Semantics(
                  liveRegion: isError,
                  child: Text(
                    text,
                    style: style.copyWith(
                      color: isError ? tokens.negative : null,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
