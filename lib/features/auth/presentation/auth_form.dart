import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../domain/auth_validators.dart';
import 'auth_metrics.dart';
import 'auth_strings.dart';
import 'widgets/shake.dart';

/// Controller, focus and validation error of one field of an auth form.
class AuthFieldState {
  AuthFieldState({required this.field, required this.validator});

  final AuthField field;
  final FieldFailure? Function(String value) validator;
  final TextEditingController controller = TextEditingController();
  final FocusNode focusNode = FocusNode();

  /// Message shown below the field, or `null`.
  String? error;

  String get text => controller.text;

  /// Validates the current text and stores the message in [error].
  bool validate() {
    final failure = validator(controller.text);
    error = failure == null ? null : AuthStrings.fieldFailure(failure, field);
    return failure == null;
  }

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

/// Validation and loading behavior shared by the auth forms:
///
/// - Fields are validated when the main button is tapped, then revalidated
///   on every change.
/// - On the first error the form shakes and the first invalid field gets
///   focus.
/// - [runBusy] shows the loading state and prevents double submits.
mixin AuthFormMixin<T extends StatefulWidget> on State<T> {
  /// The fields of the form, in visual order.
  List<AuthFieldState> get fields;

  final GlobalKey<ShakeState> shakeKey = GlobalKey<ShakeState>();

  bool get busy => _busy;
  bool _busy = false;
  bool _submitted = false;

  /// Validates every field. Returns `true` when all are valid.
  bool validateAll() {
    _submitted = true;
    var valid = true;
    for (final field in fields) {
      valid = field.validate() && valid;
    }
    setState(() {});
    if (!valid) {
      shakeKey.currentState?.shake();
      fields
          .firstWhere((field) => field.error != null)
          .focusNode
          .requestFocus();
    }
    return valid;
  }

  /// Wire to `onChanged` of each field.
  void onFieldChanged(AuthFieldState field) {
    if (!_submitted) return;
    setState(field.validate);
  }

  /// Shows the loading state while [action] runs. Ignored if already busy.
  Future<void> runBusy(Future<void> Function() action) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  /// Tells the platform the credentials were accepted (offers to save them).
  void finishAutofill() => TextInput.finishAutofillContext();

  @override
  void dispose() {
    for (final field in fields) {
      field.dispose();
    }
    super.dispose();
  }
}

/// Lowercases the text as it is typed (usernames).
class LowerCaseTextFormatter extends TextInputFormatter {
  const LowerCaseTextFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toLowerCase());
}

/// Formatters of a username field: no spaces, lowercase.
final List<TextInputFormatter> usernameFormatters = [
  FilteringTextInputFormatter.deny(RegExp(r'\s')),
  const LowerCaseTextFormatter(),
];

// TODO: replace with the real Firebase calls (auth repository) in the
// functional stage of the auth module.
/// Stand-in for a Firebase request while the module is visual only.
Future<void> simulateAuthRequest() =>
    Future<void>.delayed(AuthMetrics.simulatedRequest);
