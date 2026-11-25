import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/fbu_primary_button.dart';
import '../../../core/widgets/fbu_secondary_button.dart';
import '../../auth/data/auth_providers.dart';
import '../../auth/presentation/auth_metrics.dart';
import '../../auth/presentation/auth_text_styles.dart';
import '../../auth/presentation/widgets/auth_banner.dart';
import '../../auth/presentation/widgets/auth_scaffold.dart';
import '../../auth/presentation/widgets/fbu_text_field.dart';
import '../data/avatar_picker.dart';
import '../data/avatar_uploader.dart';
import '../data/profile_providers.dart';
import '../domain/profile_validators.dart';
import '../domain/user_profile.dart';
import 'profile_strings.dart';
import 'widgets/accent_color_picker.dart';
import 'widgets/avatar_editor.dart';
import 'widgets/avatar_source_sheet.dart';
import 'widgets/complete_profile_skeleton.dart';

/// Optional profile data after signing up: photo (Cloudinary), name and
/// color. "Omitir por ahora" keeps the defaults; both mark the profile as
/// completed, so the splash stops sending the user here.
///
/// The screen previews the chosen color as the accent.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  // DECISIÓN: offline, Firestore queues the write and its future completes
  // only when the server confirms it. After this wait the app moves on; the
  // local cache already has the change and it syncs later.
  static const Duration _writeWait = Duration(seconds: 10);

  final _name = TextEditingController();
  final _nameFocus = FocusNode();
  String? _nameError;

  /// Selected color; set from the profile once it loads.
  int? _colorValue;

  /// Cropped photo picked on this screen (not uploaded until saving).
  String? _localPhotoPath;
  bool _photoRemoved = false;

  /// Read from the server when the live profile was (still) `null`.
  UserProfile? _fetchedProfile;
  bool _checkingMissing = false;
  bool _fetchFailed = false;

  bool _busy = false;
  bool _skipping = false;
  String? _banner;

  @override
  void initState() {
    super.initState();
    ref.listenManual(
      currentUserProfileProvider,
      (_, next) => _onProfile(next),
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onProfile(AsyncValue<UserProfile?> next) {
    if (next.isLoading || next.hasError) return;
    final profile = next.value;
    if (profile == null) {
      unawaited(_checkMissingProfile());
      return;
    }
    _initFrom(profile);
  }

  /// The live profile is `null`. That is often stale: right after choosing a
  /// nickname the listener may not have received the new `users/{uid}` yet
  /// (transactions are not reflected locally until the server confirms
  /// them). So read the document from the server before redirecting.
  Future<void> _checkMissingProfile() async {
    if (_checkingMissing) return;
    final user = ref.read(firebaseAuthProvider).currentUser;
    if (user == null) {
      _goLater(AppRoutes.welcome);
      return;
    }
    _checkingMissing = true;
    try {
      final profile = await ref
          .read(userProfileRepositoryProvider)
          .fetch(user.uid);
      if (!mounted) return;
      if (profile == null) {
        _goLater(AppRoutes.chooseUsername);
      } else {
        setState(() => _fetchedProfile = profile);
        _initFrom(profile);
      }
    } catch (error, stackTrace) {
      _log('Could not read the profile', error, stackTrace);
      if (mounted) setState(() => _fetchFailed = true);
    } finally {
      _checkingMissing = false;
    }
  }

  void _goLater(String location) =>
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.go(location);
      });

  void _initFrom(UserProfile profile) {
    if (_colorValue != null) return;
    // First load: start from what the profile has.
    _colorValue = profile.colorValue;
    if (profile.displayName != profile.nickname) {
      _name.text = profile.displayName;
    }
    if (mounted) setState(() {});
  }

  ImageProvider? _image(UserProfile profile) {
    final local = _localPhotoPath;
    if (local != null) return FileImage(File(local));
    final url = profile.photoUrl;
    if (_photoRemoved || url == null) return null;
    return NetworkImage(url);
  }

  Future<void> _changePhoto(UserProfile profile) async {
    final action = await showAvatarSourceSheet(
      context,
      canRemove: _image(profile) != null,
    );
    if (action == null || !mounted) return;
    if (action == AvatarAction.remove) {
      setState(() {
        _localPhotoPath = null;
        _photoRemoved = true;
      });
      return;
    }

    final tokens = context.tokens;
    try {
      final path = await ref
          .read(avatarPickerProvider)
          .pick(
            action == AvatarAction.camera
                ? AvatarSource.camera
                : AvatarSource.gallery,
            AvatarCropStyle(
              title: ProfileStrings.cropTitle,
              background: tokens.background,
              toolbar: tokens.surface,
              foreground: tokens.textPrimary,
              active: Color(_colorValue ?? profile.colorValue),
            ),
          );
      if (path == null || !mounted) return;
      setState(() {
        _localPhotoPath = path;
        _photoRemoved = false;
        _banner = null;
      });
    } catch (error, stackTrace) {
      _log('Could not pick the avatar', error, stackTrace);
      if (mounted) setState(() => _banner = ProfileStrings.pickError);
    }
  }

  void _onNameChanged(String value) {
    if (_nameError == null) return;
    setState(() => _nameError = _nameMessage(value));
  }

  static String? _nameMessage(String value) =>
      switch (ProfileValidators.displayName(value)) {
        DisplayNameTooLong() => ProfileStrings.displayNameTooLong,
        null => null,
      };

  Future<void> _save(UserProfile profile, {required bool skip}) async {
    if (_busy) return;
    if (!skip) {
      final error = _nameMessage(_name.text);
      if (error != null) {
        setState(() => _nameError = error);
        _nameFocus.requestFocus();
        return;
      }
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _skipping = skip;
      _banner = null;
    });

    try {
      var photoUrl = profile.photoUrl;
      var displayName = profile.displayName;
      var colorValue = profile.colorValue;
      if (!skip) {
        if (_photoRemoved) photoUrl = null;
        final local = _localPhotoPath;
        if (local != null) {
          photoUrl = await ref.read(avatarUploaderProvider).upload(local);
        }
        final name = _name.text.trim();
        if (name.isNotEmpty) displayName = name;
        colorValue = _colorValue ?? colorValue;
      }
      await ref
          .read(userProfileRepositoryProvider)
          .completeProfile(
            uid: profile.uid,
            displayName: displayName,
            photoUrl: photoUrl,
            colorValue: colorValue,
          )
          .timeout(_writeWait, onTimeout: () {});
      if (mounted) context.go(AppRoutes.home);
    } on AvatarUploadException catch (error, stackTrace) {
      _log('Avatar upload failed', error, stackTrace);
      if (mounted) setState(() => _banner = ProfileStrings.uploadError);
    } catch (error, stackTrace) {
      _log('Could not save the profile', error, stackTrace);
      if (mounted) setState(() => _banner = ProfileStrings.saveError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _log(String message, Object error, StackTrace stackTrace) => developer
      .log(message, name: 'fbu.profile', error: error, stackTrace: stackTrace);

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentUserProfileProvider);
    final profile = profileAsync.value ?? _fetchedProfile;
    final colorValue = _colorValue;

    final Widget body;
    if (profile != null && colorValue != null) {
      body = _form(profile, colorValue);
    } else if ((profileAsync.hasError && !profileAsync.isLoading) ||
        _fetchFailed) {
      body = _error();
    } else {
      body = const CompleteProfileSkeleton();
    }

    final accent = Color(colorValue ?? UserProfile.defaultColorValue);
    return Theme(
      data: AppTheme.withAccent(accent),
      child: Builder(
        builder: (context) {
          final tokens = context.tokens;
          final styles = AuthTextStyles.of(context);
          final banner = _banner;
          return AuthScaffold(
            showBack: false,
            busy: _busy,
            children: [
              Text(ProfileStrings.completeTitle, style: styles.title),
              SizedBox(height: tokens.space1),
              Text(ProfileStrings.completeSubtitle, style: styles.subtitle),
              SizedBox(height: tokens.space3),
              if (banner != null) ...[
                AuthBanner(key: ValueKey(banner), message: banner),
                SizedBox(height: tokens.space2),
              ],
              body,
            ],
          );
        },
      ),
    );
  }

  Widget _error() {
    return Builder(
      builder: (context) {
        final tokens = context.tokens;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AuthBanner(message: ProfileStrings.loadError),
            SizedBox(height: tokens.space3),
            FbuSecondaryButton(
              onPressed: () {
                setState(() => _fetchFailed = false);
                ref.invalidate(currentUserProfileProvider);
              },
              child: const Text(ProfileStrings.retry),
            ),
          ],
        );
      },
    );
  }

  Widget _form(UserProfile profile, int colorValue) {
    return Builder(
      builder: (context) {
        final tokens = context.tokens;
        final textTheme = Theme.of(context).textTheme;
        final previewName = _name.text.trim();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BusyFade(
              busy: _busy,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: AvatarEditor(
                      initial: profile
                          .copyWith(
                            displayName: previewName.isEmpty
                                ? profile.displayName
                                : previewName,
                          )
                          .initial,
                      color: Color(colorValue),
                      image: _image(profile),
                      enabled: !_busy,
                      onTap: () => _changePhoto(profile),
                    ),
                  ),
                  SizedBox(height: tokens.space3),
                  FbuTextField(
                    controller: _name,
                    focusNode: _nameFocus,
                    label: ProfileStrings.displayNameLabel,
                    hint: ProfileStrings.displayNameHint,
                    helperText: ProfileStrings.displayNameHelper,
                    errorText: _nameError,
                    enabled: !_busy,
                    textCapitalization: TextCapitalization.words,
                    autofillHints: const [AutofillHints.name],
                    textInputAction: TextInputAction.done,
                    onChanged: (value) {
                      _onNameChanged(value);
                      // Refreshes the initial of the avatar.
                      setState(() {});
                    },
                  ),
                  SizedBox(height: tokens.space3),
                  Text(ProfileStrings.colorLabel, style: textTheme.titleSmall),
                  const SizedBox(height: AuthMetrics.helperGap),
                  Text(
                    ProfileStrings.colorHelper,
                    style: AuthTextStyles.of(context).helper,
                  ),
                  SizedBox(height: tokens.space1),
                  AccentColorPicker(
                    colorValue: colorValue,
                    enabled: !_busy,
                    onChanged: (value) => setState(() => _colorValue = value),
                  ),
                ],
              ),
            ),
            SizedBox(height: tokens.space3),
            FbuPrimaryButton(
              onPressed: () => _save(profile, skip: false),
              isLoading: _busy && !_skipping,
              loadingSemanticsLabel: ProfileStrings.saving,
              child: const Text(ProfileStrings.save),
            ),
            const SizedBox(height: AuthMetrics.buttonGap),
            FbuSecondaryButton(
              onPressed: _busy ? null : () => _save(profile, skip: true),
              isLoading: _busy && _skipping,
              loadingSemanticsLabel: ProfileStrings.saving,
              child: const Text(ProfileStrings.skip),
            ),
          ],
        );
      },
    );
  }
}
