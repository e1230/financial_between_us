import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/fbu_secondary_button.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/presentation/auth_metrics.dart';
import '../../auth/presentation/auth_text_styles.dart';
import '../../auth/presentation/widgets/auth_banner.dart';
import '../data/avatar_uploader.dart';
import '../data/profile_providers.dart';
import '../domain/profile_validators.dart';
import '../domain/user_profile.dart';
import 'pick_avatar.dart';
import 'profile_strings.dart';
import 'widgets/change_password_dialog.dart';
import 'widgets/profile_form.dart';
import 'widgets/profile_form_skeleton.dart';

/// "Perfil" tab: edit the photo, the visible name and the color; see the
/// nickname, the email and how the user signs in; change the password.
///
/// Nothing is written until "Guardar". "Cancelar" drops the changes and
/// returns to Inicio. The screen previews the chosen color as the accent.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // DECISIÓN: same offline criterion as "Completa tu perfil": after this wait
  // the local cache already has the change and it syncs later.
  static const Duration _writeWait = Duration(seconds: 10);

  final _name = TextEditingController();
  final _nameFocus = FocusNode();
  String? _nameError;

  /// Latest profile from Firestore (or the one just saved).
  UserProfile? _profile;

  // Draft.
  int? _colorValue;
  String? _localPhotoPath;
  bool _photoRemoved = false;

  /// Bumped on every reset so the color picker drops its own state.
  int _draftVersion = 0;

  bool _busy = false;
  ({String message, AuthBannerKind kind})? _notice;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      currentUserProfileProvider,
      (_, next) => _onProfile(next.value),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onProfile(UserProfile? next) {
    if (next == null) return;
    final previous = _profile;
    // Keep what the user is editing; otherwise follow the server.
    final keepDraft = previous != null && _isDirty(previous);
    setState(() {
      _profile = next;
      if (!keepDraft) _resetDraft(next);
    });
  }

  void _resetDraft(UserProfile profile) {
    _name.text = profile.displayName;
    _nameError = null;
    _colorValue = profile.colorValue;
    _localPhotoPath = null;
    _photoRemoved = false;
    _draftVersion++;
  }

  bool _isDirty(UserProfile profile) {
    final name = _name.text.trim();
    return (name.isNotEmpty && name != profile.displayName) ||
        (_colorValue != null && _colorValue != profile.colorValue) ||
        _localPhotoPath != null ||
        (_photoRemoved && profile.photoUrl != null);
  }

  ImageProvider? _image(UserProfile profile) {
    final local = _localPhotoPath;
    if (local != null) return FileImage(File(local));
    final url = profile.photoUrl;
    if (_photoRemoved || url == null) return null;
    return NetworkImage(url);
  }

  Future<void> _changePhoto(UserProfile profile) async {
    try {
      final change = await pickAvatar(
        context,
        ref,
        canRemove: _image(profile) != null,
        accent: Color(_colorValue ?? profile.colorValue),
      );
      if (change == null || !mounted) return;
      setState(() {
        _notice = null;
        switch (change) {
          case AvatarPhotoPicked(:final path):
            _localPhotoPath = path;
            _photoRemoved = false;
          case AvatarPhotoRemoved():
            _localPhotoPath = null;
            _photoRemoved = true;
        }
      });
    } catch (error, stackTrace) {
      _log('Could not pick the avatar', error, stackTrace);
      if (mounted) _show(ProfileStrings.pickError);
    }
  }

  void _onNameChanged(String value) => setState(() {
    _notice = null;
    if (_nameError != null) _nameError = _nameMessage(value);
  });

  static String? _nameMessage(String value) {
    final failure = ProfileValidators.displayName(value);
    return failure == null ? null : ProfileStrings.field(failure);
  }

  void _show(String message, {AuthBannerKind kind = AuthBannerKind.error}) =>
      setState(() => _notice = (message: message, kind: kind));

  Future<void> _save() async {
    final profile = _profile;
    if (profile == null || _busy) return;
    final error = _nameMessage(_name.text);
    if (error != null) {
      setState(() => _nameError = error);
      _nameFocus.requestFocus();
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _notice = null;
    });

    try {
      var photoUrl = _photoRemoved ? null : profile.photoUrl;
      final local = _localPhotoPath;
      if (local != null) {
        photoUrl = await ref.read(avatarUploaderProvider).upload(local);
      }
      final typed = _name.text.trim();
      final saved = profile.copyWith(
        displayName: typed.isEmpty ? profile.displayName : typed,
        photoUrl: photoUrl,
        colorValue: _colorValue ?? profile.colorValue,
      );
      await ref
          .read(userProfileRepositoryProvider)
          .updateProfile(
            uid: saved.uid,
            displayName: saved.displayName,
            photoUrl: saved.photoUrl,
            colorValue: saved.colorValue,
          )
          .timeout(_writeWait, onTimeout: () {});
      if (!mounted) return;
      setState(() {
        _profile = saved;
        _resetDraft(saved);
      });
      _show(ProfileStrings.saved, kind: AuthBannerKind.success);
    } on AvatarUploadException catch (error, stackTrace) {
      _log('Avatar upload failed', error, stackTrace);
      if (mounted) _show(ProfileStrings.uploadError);
    } catch (error, stackTrace) {
      _log('Could not save the profile', error, stackTrace);
      if (mounted) _show(ProfileStrings.saveError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _cancel() {
    FocusScope.of(context).unfocus();
    final profile = _profile;
    setState(() {
      _notice = null;
      if (profile != null) _resetDraft(profile);
    });
    context.go(AppRoutes.home);
  }

  Future<void> _changePassword() async {
    setState(() => _notice = null);
    final changed = await showChangePasswordDialog(context);
    if (changed && mounted) {
      _show(ProfileStrings.passwordChanged, kind: AuthBannerKind.success);
    }
  }

  void _log(String message, Object error, StackTrace stackTrace) => developer
      .log(message, name: 'fbu.profile', error: error, stackTrace: stackTrace);

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final signInMethod = ref.watch(currentSignInMethodProvider).value;
    final profile = _profile;
    final colorValue = _colorValue;

    final Widget body;
    if (profile != null && colorValue != null) {
      body = ProfileForm(
        profile: profile,
        name: _name,
        nameFocus: _nameFocus,
        nameError: _nameError,
        colorValue: colorValue,
        image: _image(profile),
        signInMethod: signInMethod,
        busy: _busy,
        canSave: _isDirty(profile),
        colorPickerKey: ValueKey(_draftVersion),
        onPhotoTap: () => _changePhoto(profile),
        onNameChanged: _onNameChanged,
        onColorChanged: (value) => setState(() {
          _notice = null;
          _colorValue = value;
        }),
        onChangePassword: _changePassword,
        onSave: _save,
        onCancel: _cancel,
      );
    } else if (!profileAsync.isLoading &&
        (profileAsync.hasError || profileAsync.value == null)) {
      body = _ProfileLoadError(
        onRetry: () => ref.invalidate(currentUserProfileProvider),
      );
    } else {
      body = const ProfileFormSkeleton();
    }

    final accent = Color(colorValue ?? UserProfile.defaultColorValue);
    return Theme(
      data: AppTheme.withAccent(accent),
      child: Builder(
        builder: (context) {
          final tokens = context.tokens;
          final styles = AuthTextStyles.of(context);
          final padding = MediaQuery.paddingOf(context);
          final notice = _notice;
          return Scaffold(
            backgroundColor: tokens.background,
            body: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                tokens.space3,
                padding.top + tokens.space3,
                tokens.space3,
                // The shell extends its body behind the bottom bar, so this
                // padding already includes the bar.
                padding.bottom + tokens.space3,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AuthMetrics.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          ProfileStrings.profileTitle,
                          style: styles.title,
                        ),
                      ),
                      SizedBox(height: tokens.space1),
                      Text(
                        ProfileStrings.profileSubtitle,
                        style: styles.subtitle,
                      ),
                      SizedBox(height: tokens.space3),
                      if (notice != null) ...[
                        AuthBanner(
                          key: ValueKey(notice),
                          message: notice.message,
                          kind: notice.kind,
                        ),
                        SizedBox(height: tokens.space2),
                      ],
                      body,
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The profile could not be loaded.
class _ProfileLoadError extends StatelessWidget {
  const _ProfileLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const AuthBanner(message: ProfileStrings.loadError),
        SizedBox(height: context.tokens.space3),
        FbuSecondaryButton(
          onPressed: onRetry,
          child: const Text(ProfileStrings.retry),
        ),
      ],
    );
  }
}
