/// Hides an email address keeping only its first letter and domain, e.g.
/// `juan@correo.com` → `j•••@correo.com`.
///
/// Values without a local part or domain are masked entirely.
String maskEmail(String email) {
  const mask = '•••';
  final value = email.trim();
  final at = value.lastIndexOf('@');
  if (at <= 0 || at == value.length - 1) return mask;
  return '${value[0]}$mask${value.substring(at)}';
}
