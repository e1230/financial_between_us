import 'package:material_ui/material_ui.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/profile/data/profile_providers.dart';
import '../utils/accent_color.dart';
import 'app_theme.dart';

part 'app_theme_provider.g.dart';

/// Theme of the app: the dark theme with the signed-in user's color as the
/// accent. Signed out (or with an unreadable stored color) it is the brand
/// green.
@Riverpod(keepAlive: true)
ThemeData appTheme(Ref ref) {
  final colorValue = ref.watch(currentUserProfileProvider).value?.colorValue;
  final accent = colorValue == null ? null : Color(colorValue);
  if (accent == null || !AccentColor.isReadable(accent)) return AppTheme.dark;
  return AppTheme.withAccent(accent);
}
