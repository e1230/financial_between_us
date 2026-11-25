import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_tokens.dart';
import '../../../../core/theme/user_palette.dart';
import '../home_strings.dart';
import '../home_text_styles.dart';

/// "Hola, {first name}" painted with a horizontal gradient of the user's
/// color into the brand green.
class Greeting extends StatelessWidget {
  const Greeting({super.key, required this.name});

  /// Display name (or nickname); only its first word is shown.
  final String name;

  static const List<double> stops = [0, 0.45, 1];

  /// First word of [name].
  static String firstName(String name) {
    final words = name.trim().split(RegExp(r'\s+'));
    return words.first;
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.userPalette;
    final gradient = LinearGradient(
      colors: [palette.userSoft, palette.userColor, context.tokens.glowBright],
      stops: stops,
    );
    return Semantics(
      header: true,
      child: Align(
        alignment: Alignment.centerLeft,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: gradient.createShader,
          child: Text(
            HomeStrings.greeting(firstName(name)),
            style: HomeTextStyles.of(context).greeting,
          ),
        ),
      ),
    );
  }
}
