import '../domain/auth_validators.dart';

/// Fields whose "required" message differs.
enum AuthField { username, email, password, loginIdentifier, loginPassword }

/// User-facing texts of the auth module (Spanish, Colombia).
abstract final class AuthStrings {
  // Shared
  static const back = 'Volver';
  static const or = 'o';
  static const continueWithGoogle = 'Continuar con Google';
  static const showPassword = 'Mostrar contraseña';
  static const hidePassword = 'Ocultar contraseña';
  static const passwordHint = '••••••••';
  static const passwordHelper = 'Mínimo 8 caracteres.';
  static const usernameLabel = 'Nombre de usuario';
  static const usernameHint = 'ej. juanes_92';
  static const emailLabel = 'Correo electrónico';
  static const emailHint = 'nombre@correo.com';
  static const passwordLabel = 'Contraseña';
  static const signInLink = 'Inicia sesión';

  // Loading labels (screen readers)
  static const creatingAccount = 'Creando cuenta';
  static const sending = 'Enviando';
  static const saving = 'Guardando';

  // Welcome
  static const welcomeTitle = 'Ingresa al aplicativo';
  static const createAccount = 'Crear cuenta';
  static const signIn = 'Iniciar sesión';

  // Register
  static const registerTitle = 'Crea tu cuenta';
  static const registerFooter = '¿Ya tienes cuenta?';

  // Login
  static const loginTitle = 'Hola de nuevo';
  static const loginSubtitle = 'Entra para ver tus gastos';
  static const loginIdentifierLabel = 'Usuario o correo';
  static const loginIdentifierHint = 'juanes_92 o nombre@correo.com';
  static const forgotPassword = '¿Olvidaste tu contraseña?';
  static const loginFooter = '¿No tienes cuenta?';
  static const loginFooterLink = 'Crea una';
  static const signingIn = 'Iniciando sesión';

  // Recover
  static const recoverTitle = 'Recupera tu contraseña';
  static const recoverSubtitle =
      'Te enviaremos un enlace al correo para confirmar el cambio.';
  static const newPasswordLabel = 'Nueva contraseña';
  static const send = 'Enviar';
  static const recoverFooter = '¿Ya la recordaste?';

  // Recover · sent
  static const sentTitle = 'Revisa tu correo';
  static String sentBody(String maskedEmail) =>
      'Enviamos un enlace a $maskedEmail. '
      'Ábrelo para confirmar tu nueva contraseña.';
  static const backToSignIn = 'Volver a iniciar sesión';
  static String resendIn(Duration left) {
    final seconds = left.inSeconds;
    final minutes = seconds ~/ 60;
    final rest = (seconds % 60).toString().padLeft(2, '0');
    return 'Reenviar en $minutes:$rest';
  }

  static const resend = 'Reenviar correo';
  static const spamNote = '¿No llega? Revisa la carpeta de spam.';

  // Choose username
  static const chooseUsernameTitle = 'Elige tu nombre de usuario';
  static const chooseUsernameSubtitle =
      'Así te encontrarán tus amigos en el grupo.';
  static const continueLabel = 'Continuar';

  /// Message of a client-side validation [failure] of [field].
  static String fieldFailure(
    FieldFailure failure,
    AuthField field,
  ) => switch (failure) {
    FieldRequired() => switch (field) {
      AuthField.username => 'Escribe un nombre de usuario.',
      AuthField.email => 'Escribe tu correo.',
      AuthField.password => passwordTooShort(AuthValidators.minPasswordLength),
      AuthField.loginIdentifier => 'Escribe tu usuario o tu correo.',
      AuthField.loginPassword => 'Escribe tu contraseña.',
    },
    UsernameInvalid() => 'Usa de 3 a 20 letras, números, punto o guion bajo.',
    EmailInvalid() => 'Escribe un correo válido.',
    PasswordTooShort(:final missing) => passwordTooShort(missing),
  };

  static String passwordTooShort(int missing) => missing == 1
      ? 'Le falta 1 carácter: mínimo 8.'
      : 'Le faltan $missing caracteres: mínimo 8.';
}
