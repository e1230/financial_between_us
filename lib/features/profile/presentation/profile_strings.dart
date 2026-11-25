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
