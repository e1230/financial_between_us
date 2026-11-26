import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../../core/widgets/fbu_toast.dart';
import '../../../auth/data/auth_providers.dart';
import '../../../auth/presentation/widgets/fbu_text_field.dart';
import '../../data/payment_accounts_providers.dart';
import '../../domain/payment_account.dart';
import '../../domain/payment_account_rules.dart';
import '../dialogs/account_failure_message.dart';
import '../dialogs/discard_changes_dialog.dart';
import '../payment_accounts_metrics.dart';
import '../payment_accounts_strings.dart';
import '../payment_accounts_text_styles.dart';
import 'key_type_chips.dart';
import 'reference_input.dart';
import 'type_field.dart';
import 'type_tiles.dart';

/// What the form saved, for the list to confirm it.
enum AccountFormResult {
  /// "Cuenta guardada".
  created,

  /// "Cambios guardados".
  updated,
}

/// Full-screen form to create a payment account, or edit [initial].
///
/// Fields are validated when they lose focus and when "Guardar" is
/// tapped, never on every key. "Guardar" stays gray until the form is
/// valid. Closing with unsaved changes asks first. Pops with an
/// [AccountFormResult] once saved.
class PaymentAccountFormScreen extends ConsumerStatefulWidget {
  const PaymentAccountFormScreen({super.key, this.initial});

  /// The account being edited, or `null` to create one.
  final PaymentAccount? initial;

  @override
  ConsumerState<PaymentAccountFormScreen> createState() =>
      _PaymentAccountFormScreenState();
}

class _PaymentAccountFormScreenState
    extends ConsumerState<PaymentAccountFormScreen> {
  late final TextEditingController _name = TextEditingController(
    text: widget.initial?.name ?? '',
  );
  late final TextEditingController _reference = TextEditingController(
    text: widget.initial?.reference ?? '',
  );
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _referenceFocus = FocusNode();

  late PaymentAccountType? _type = widget.initial?.type;
  late BrebKeyType? _keyType = widget.initial?.keyType;

  /// The name was filled in from the type (and not typed since).
  String? _autoName;
  bool _nameTouched = false;
  bool _referenceTouched = false;

  /// The reference field had focus since its kind last changed: losing it
  /// then (not when the field is rebuilt for another kind) validates it.
  bool _referenceFocused = false;
  bool _saving = false;

  bool get _isEditing => widget.initial != null;

  ReferenceInput get _input => ReferenceInput.of(_type, _keyType);

  @override
  void initState() {
    super.initState();
    _nameFocus.addListener(() {
      if (!_nameFocus.hasFocus) setState(() => _nameTouched = true);
    });
    _referenceFocus.addListener(() {
      if (_referenceFocus.hasFocus) {
        _referenceFocused = true;
      } else if (_referenceFocused && _input.enabled) {
        setState(() => _referenceTouched = true);
      }
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _reference.dispose();
    _nameFocus.dispose();
    _referenceFocus.dispose();
    super.dispose();
  }

  NameError? get _nameError => PaymentAccountRules.validateName(_name.text);

  ReferenceError? get _referenceError {
    final kind = _input.kind;
    if (_type == null) return null;
    if (_type == PaymentAccountType.breb && kind == ReferenceKind.none) {
      // A Bre-B key without key type is not valid yet.
      return ReferenceError.empty;
    }
    return PaymentAccountRules.validateReference(kind, _reference.text);
  }

  bool get _isValid =>
      _type != null && _nameError == null && _referenceError == null;

  /// The account as the form describes it now (only valid when [_isValid]).
  PaymentAccount _draft() {
    final type = _type!;
    final kind = _input.kind;
    return PaymentAccount(
      id: widget.initial?.id ?? '',
      name: _name.text.trim(),
      type: type,
      keyType: type == PaymentAccountType.breb ? _keyType : null,
      reference: PaymentAccountRules.normalizeReference(kind, _reference.text),
      createdAt: widget.initial?.createdAt,
    );
  }

  bool get _isDirty {
    final initial = widget.initial;
    if (initial == null) {
      return _type != null ||
          _name.text.trim().isNotEmpty ||
          _reference.text.trim().isNotEmpty;
    }
    return _name.text.trim() != initial.name ||
        _type != initial.type ||
        _keyType != initial.keyType ||
        PaymentAccountRules.normalizeReference(_input.kind, _reference.text) !=
            initial.reference;
  }

  void _selectType(PaymentAccountType type) {
    if (type == _type) return;
    setState(() {
      _type = type;
      _keyType = null;
      _reference.clear();
      _referenceTouched = false;
      _referenceFocused = false;
      // DECISIÓN: a name that was filled in from the previous type follows
      // the new one, so switching types never leaves a wrong name.
      final name = _name.text.trim();
      if (name.isEmpty || name == _autoName) {
        final suggested = PaymentAccountsStrings.defaultName(type);
        _name.text = suggested ?? '';
        _autoName = suggested;
      }
    });
  }

  void _selectKeyType(BrebKeyType keyType) {
    if (keyType == _keyType) return;
    setState(() {
      _keyType = keyType;
      _reference.clear();
      _referenceTouched = false;
      _referenceFocused = false;
    });
  }

  Future<void> _close() async {
    if (!_isDirty || await showDiscardChangesDialog(context)) {
      if (mounted) Navigator.of(context).pop();
    }
  }

  Future<void> _save() async {
    setState(() {
      _nameTouched = true;
      _referenceTouched = true;
    });
    if (!_isValid || _saving) return;
    final uid = ref.read(authStateChangesProvider).value?.uid;
    if (uid == null) return;
    FocusScope.of(context).unfocus();
    setState(() => _saving = true);
    final repository = ref.read(paymentAccountsRepositoryProvider);
    final account = _draft();
    try {
      if (_isEditing) {
        await repository.update(uid: uid, account: account);
      } else {
        await repository.create(uid: uid, account: account);
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      FbuToast.show(context, accountFailureMessage(error));
      return;
    }
    if (!mounted) return;
    Navigator.of(
      context,
    ).pop(_isEditing ? AccountFormResult.updated : AccountFormResult.created);
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final styles = PaymentAccountsTextStyles.of(context);
    final padding = MediaQuery.paddingOf(context);
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final input = _input;
    final nameError = _nameTouched ? _nameError : null;
    final referenceError = _referenceTouched && input.enabled
        ? _referenceError
        : null;
    final showKeyTypes = _type == PaymentAccountType.breb;
    final showReference = _type != PaymentAccountType.cash;
    final sizeDuration = reduceMotion ? Duration.zero : tokens.motionShort;

    return PopScope(
      canPop: !_isDirty || _saving,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _close();
      },
      child: Scaffold(
        backgroundColor: tokens.background,
        resizeToAvoidBottomInset: true,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: padding.top + PaymentAccountsMetrics.barTop),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(
                  start: PaymentAccountsMetrics.backInset,
                ),
                child: IconButton(
                  onPressed: _saving ? null : _close,
                  tooltip: PaymentAccountsStrings.close,
                  icon: Icon(
                    Icons.close,
                    size: PaymentAccountsMetrics.backIconSize,
                    color: tokens.textPrimary,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  tokens.space3,
                  PaymentAccountsMetrics.titleGap,
                  tokens.space3,
                  tokens.space3,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Semantics(
                      header: true,
                      child: Text(
                        _isEditing
                            ? PaymentAccountsStrings.editTitle
                            : PaymentAccountsStrings.newTitle,
                        style: styles.formTitle,
                      ),
                    ),
                    const SizedBox(
                      height: PaymentAccountsMetrics.formFieldsGap,
                    ),
                    FbuTextField(
                      controller: _name,
                      focusNode: _nameFocus,
                      label: PaymentAccountsStrings.nameLabel,
                      hint: PaymentAccountsStrings.nameHint,
                      errorText: nameError == null
                          ? null
                          : PaymentAccountsStrings.nameError(nameError),
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(
                          PaymentAccountRules.nameMaxLength,
                        ),
                      ],
                      onChanged: (_) => setState(() => _autoName = null),
                    ),
                    const SizedBox(height: PaymentAccountsMetrics.fieldGap),
                    TypeField(type: _type),
                    const SizedBox(height: PaymentAccountsMetrics.tilesGap),
                    TypeTiles(selected: _type, onSelect: _selectType),
                    _Reveal(
                      visible: showKeyTypes,
                      duration: sizeDuration,
                      fadeIn: reduceMotion
                          ? PaymentAccountsMetrics.reducedFade
                          : tokens.motionShort,
                      fadeOut: tokens.motionFast,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: PaymentAccountsMetrics.fieldGap,
                        ),
                        child: KeyTypeChips(
                          selected: _keyType,
                          onSelect: _selectKeyType,
                        ),
                      ),
                    ),
                    _Reveal(
                      visible: showReference,
                      duration: sizeDuration,
                      fadeIn: reduceMotion
                          ? PaymentAccountsMetrics.reducedFade
                          : tokens.motionFast,
                      fadeOut: tokens.motionFast,
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: PaymentAccountsMetrics.fieldGap,
                        ),
                        child: Opacity(
                          opacity: input.enabled
                              ? 1
                              : PaymentAccountsMetrics.disabledOpacity,
                          // DECISIÓN: the label and placeholder switch at
                          // once (no cross-fade): both fields would share
                          // one focus node during the transition.
                          child: FbuTextField(
                            // A new field (label, keyboard, filters) for
                            // each kind of reference.
                            key: ValueKey(input.kind),
                            controller: _reference,
                            focusNode: _referenceFocus,
                            enabled: input.enabled,
                            label: input.label,
                            hint: input.hint,
                            helperText: input.helper,
                            errorText: referenceError == null
                                ? null
                                : PaymentAccountsStrings.referenceError(
                                    referenceError,
                                  ),
                            keyboardType: input.keyboardType,
                            inputFormatters: input.formatters,
                            autocorrect: false,
                            textInputAction: TextInputAction.done,
                            onChanged: (_) => setState(() {}),
                            onSubmitted: (_) => _save(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                tokens.space3,
                tokens.space1,
                tokens.space3,
                keyboardOpen
                    ? tokens.space2
                    : padding.bottom + PaymentAccountsMetrics.bottomButtonGap,
              ),
              // A tap on the gray "Guardar" still shows what is missing.
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _isValid ? null : _save,
                child: FbuPrimaryButton(
                  onPressed: _isValid ? _save : null,
                  isLoading: _saving,
                  loadingSemanticsLabel: PaymentAccountsStrings.saving,
                  child: const Text(PaymentAccountsStrings.save),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows or hides [child] with a fade and a size change.
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.visible,
    required this.duration,
    required this.fadeIn,
    required this.fadeOut,
    required this.child,
  });

  final bool visible;
  final Duration duration;
  final Duration fadeIn;
  final Duration fadeOut;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      alignment: Alignment.topCenter,
      child: AnimatedSwitcher(
        duration: fadeIn,
        reverseDuration: fadeOut,
        child: visible
            ? KeyedSubtree(key: const ValueKey(true), child: child)
            : const SizedBox(key: ValueKey(false), width: double.infinity),
      ),
    );
  }
}
