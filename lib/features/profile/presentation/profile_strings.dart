import '../../auth/domain/auth_failure.dart';
import '../../auth/domain/auth_validators.dart';
import '../domain/profile_validators.dart';

/// User-facing texts of the profile module (Spanish, Colombia).
abstract final class ProfileStrings {
  // Complete profile
  static const completeTitle = 'Completa tu perfil';
  static const completeSubtitle =
      'Así te verán tus amigos. Puedes cambiarlo después.';
  static const displayNameLabel = 'Nombres';
  static const displayNameHint = 'ej. Mauricio Beltrán';
  static const displayNameHelper = 'Opcional. Así aparecerás en los grupos.';
  static const displayNameTooLong = 'Usa máximo 40 caracteres.';
  static const colorLabel = 'Tu color';
  static const colorHelper = 'Cambia el color de la app para ti.';
  static const save = 'Guardar';
  static const saving = 'Guardando';
  static const skip = 'Omitir por ahora';
  static const loadError = 'No pudimos cargar tu perfil.';
  static const retry = 'Reintentar';
  static const loading = 'Cargando tu perfil';
  static const saveError =
      'No pudimos guardar tu perfil. Revisa tu conexión e intenta de nuevo.';
  static const uploadError =
      'No pudimos subir la foto. Revisa tu conexión e intenta de nuevo.';
  static const pickError = 'No pudimos abrir la foto. Intenta con otra.';

  // Profile (tab)
  static const profileTitle = 'Perfil';
  static const profileSubtitle = 'Así te ven tus amigos en los grupos.';
  static const usernameLabel = 'Usuario';
  static const emailLabel = 'Correo';
  static const displayNameEditHelper = 'Así aparecerás en los grupos.';
  static const accountLabel = 'Tu cuenta';
  static const readOnlyHelper = 'Tu usuario y tu correo no se pueden cambiar.';
  static const cancel = 'Cancelar';
  static const saved = 'Perfil actualizado.';
  static const passwordLabel = 'Contraseña';
  static const passwordMask = '••••••••';
  static const changePassword = 'Cambiar';
  static const changePasswordAction = 'Cambiar contraseña';
  static const signedInWithGoogle = 'Ingresado con Google';
  static const googlePasswordHelper = 'Tu contraseña la maneja Google.';

  // Change password popup
  static const changePasswordTitle = 'Cambiar contraseña';
  static const changePasswordSubtitle =
      'Por seguridad, primero escribe tu contraseña actual.';
  static const currentPassword = 'Contraseña actual';
  static const newPassword = 'Nueva contraseña';
  static const confirmPassword = 'Confirma la nueva contraseña';
  static const newPasswordHelper = 'Mínimo 8 caracteres.';
  static const changingPassword = 'Cambiando contraseña';
  static const passwordChanged = 'Contraseña actualizada.';
  static const wrongCurrentPassword = 'La contraseña actual no es correcta.';

  /// Message of a field failure of the profile forms.
  static String field(ProfileFieldFailure failure) => switch (failure) {
    DisplayNameTooLong() => displayNameTooLong,
    CurrentPasswordRequired() => 'Escribe tu contraseña actual.',
    NewPasswordTooShort() =>
      'Usa al menos ${AuthValidators.minPasswordLength} caracteres.',
    SameAsCurrentPassword() => 'Usa una contraseña distinta a la actual.',
    PasswordsDoNotMatch() => 'Las contraseñas no coinciden.',
  };

  /// Message of a failed password change (shown in the popup's banner).
  static String passwordFailure(AuthFailure failure) => switch (failure) {
    InvalidCredentials() => wrongCurrentPassword,
    WeakPassword() => 'Usa una contraseña más segura.',
    TooManyRequests() =>
      'Demasiados intentos. Espera unos minutos e intenta de nuevo.',
    NetworkFailure() => 'Sin conexión. Revisa tu internet e intenta de nuevo.',
    _ => 'No pudimos cambiar la contraseña. Intenta de nuevo.',
  };

  // Avatar
  static const avatarLabel = 'Foto de perfil';
  static const changePhoto = 'Cambiar foto de perfil';
  static const fromGallery = 'Elegir de la galería';
  static const fromCamera = 'Tomar una foto';
  static const removePhoto = 'Quitar foto';
  static const cropTitle = 'Ajusta tu foto';

  // Color picker
  static const customColor = 'Color personalizado';
  static const hue = 'Tono';
  static const shade = 'Saturación y brillo';
  static String selected(String name) => '$name, seleccionado';

  /// Names of `AccentColor.presets`, in the same order.
  static const presetNames = [
    'Verde',
    'Celeste',
    'Turquesa',
    'Lavanda',
    'Violeta',
    'Rosado',
    'Coral',
    'Ámbar',
    'Amarillo',
    'Lima',
  ];
}
