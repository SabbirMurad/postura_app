/// The backend's password policy, checked on the device first so the user sees
/// the problem before submitting. The server still enforces it (and also
/// rejects common passwords and the email address).
String? passwordProblem(String password) {
  if (password.length < 8) return 'Password must be at least 8 characters.';
  if (password.length > 128) return 'Password must be at most 128 characters.';
  final hasLetter = password.runes.any(
    (r) => String.fromCharCode(r).toLowerCase() != String.fromCharCode(r).toUpperCase(),
  );
  final hasDigit = RegExp(r'[0-9]').hasMatch(password);
  if (!hasLetter || !hasDigit) {
    return 'Password must contain both letters and numbers.';
  }
  return null;
}
