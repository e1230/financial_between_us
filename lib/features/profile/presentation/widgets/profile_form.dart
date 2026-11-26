import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/widgets/fbu_primary_button.dart';
import '../../../../core/widgets/fbu_secondary_button.dart';
import '../../../auth/domain/sign_in_method.dart';
import '../../../auth/presentation/auth_metrics.dart';
import '../../../auth/presentation/auth_text_styles.dart';
import '../../../auth/presentation/widgets/auth_scaffold.dart';
import '../../../auth/presentation/widgets/fbu_text_field.dart';
import '../../../home/presentation/widgets/ring_avatar.dart';
import '../../domain/user_profile.dart';
import '../profile_strings.dart';
import 'accent_color_picker.dart';
import 'avatar_editor.dart';
import 'password_section.dart';
import 'profile_avatar_shuttle.dart';
import 'profile_info_tile.dart';

/// Fields and buttons of the profile tab. Stateless: the draft lives in
/// `ProfileScreen`.
class ProfileForm extends StatelessWidget {
  const ProfileForm({
    super.key,
    required this.profile,
    required this.name,
    required this.nameFocus,
    required this.nameError,
    required this.colorValue,
    required this.image,
    required this.signInMethod,
    required this.busy,
    required this.canSave,
    required this.colorPickerKey,
    required this.onPhotoTap,
    required this.onNameChanged,
    required this.onColorChanged,
    required this.onChangePassword,
    required this.onSave,
    required this.onCancel,
  });

  final UserProfile profile;
  final TextEditingController name;
  final FocusNode nameFocus;
  final String? nameError;
  final int colorValue;
  final ImageProvider? image;
  final SignInMethod? signInMethod;
  final bool busy;
  final bool canSave;

  /// Changes when the draft is reset, so the picker drops its own state.
  final Key colorPickerKey;
  final VoidCallback onPhotoTap;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<int> onColorChanged;
  final VoidCallback onChangePassword;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final textTheme = Theme.of(context).textTheme;
    final styles = AuthTextStyles.of(context);
    final typedName = name.text.trim();
    final previewName = typedName.isEmpty ? profile.displayName : typedName;

    Widget section(String title) => Padding(
      padding: EdgeInsets.only(bottom: tokens.space1),
      child: Semantics(
        header: true,
        child: Text(title, style: textTheme.titleSmall),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BusyFade(
          busy: busy,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  HeroMode(
                    // Only while Perfil is the visible tab: the Home header
                    // has its own avatar Hero with the same tag.
                    enabled:
                        !MediaQuery.disableAnimationsOf(context) &&
                        TickerMode.valuesOf(context).enabled,
                    child: AvatarEditor(
                      initial: profile
                          .copyWith(displayName: previewName)
                          .initial,
                      color: Color(colorValue),
                      image: image,
                      enabled: !busy,
                      onTap: onPhotoTap,
                      heroTag: RingAvatar.heroTag,
                      flightShuttleBuilder: profileAvatarShuttle,
                    ),
                  ),
                  SizedBox(width: tokens.space2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(previewName, style: textTheme.titleLarge),
                        Text('@${profile.nickname}', style: styles.footer),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: tokens.space3),
              FbuTextField(
                controller: name,
                focusNode: nameFocus,
                label: ProfileStrings.displayNameLabel,
                hint: profile.displayName,
                helperText: ProfileStrings.displayNameEditHelper,
                errorText: nameError,
                enabled: !busy,
                textCapitalization: TextCapitalization.words,
                autofillHints: const [AutofillHints.name],
                textInputAction: TextInputAction.done,
                onChanged: onNameChanged,
              ),
              SizedBox(height: tokens.space3),
              section(ProfileStrings.colorLabel),
              AccentColorPicker(
                key: colorPickerKey,
                colorValue: colorValue,
                enabled: !busy,
                onChanged: onColorChanged,
              ),
              SizedBox(height: tokens.space3),
              section(ProfileStrings.accountLabel),
              ProfileInfoTile(
                label: ProfileStrings.usernameLabel,
                value: '@${profile.nickname}',
              ),
              const SizedBox(height: AuthMetrics.fieldGap),
              ProfileInfoTile(
                label: ProfileStrings.emailLabel,
                value: profile.email,
                helper: ProfileStrings.readOnlyHelper,
              ),
              const SizedBox(height: AuthMetrics.fieldGap),
              PasswordSection(
                method: signInMethod,
                enabled: !busy,
                onChangePassword: onChangePassword,
              ),
            ],
          ),
        ),
        SizedBox(height: tokens.space4),
        FbuPrimaryButton(
          onPressed: canSave ? onSave : null,
          isLoading: busy,
          loadingSemanticsLabel: ProfileStrings.saving,
          child: const Text(ProfileStrings.save),
        ),
        const SizedBox(height: AuthMetrics.buttonGap),
        FbuSecondaryButton(
          onPressed: busy ? null : onCancel,
          child: const Text(ProfileStrings.cancel),
        ),
      ],
    );
  }
}
