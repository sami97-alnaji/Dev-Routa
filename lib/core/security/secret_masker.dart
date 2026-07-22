abstract final class SecretMasker {
  static String mask(String value) {
    if (value.isEmpty) return value;
    if (value.length <= 4) return '*' * value.length;
    return '${value.substring(0, 3)}${'*' * (value.length - 3)}';
  }

  static Map<String, String> redactHeaders(Map<String, String> headers) => {
    for (final entry in headers.entries)
      entry.key: _isSensitive(entry.key) ? '[REDACTED]' : entry.value,
  };

  /// Redacts common key/value secret shapes in payloads before they reach
  /// history, exports, diagnostics, or optional AI payload construction.
  static String redactText(String value) => value.replaceAllMapped(
    RegExp(
      r'(authorization|api[-_ ]?key|access[-_ ]?token|refresh[-_ ]?token|token|password|cookie|secret)(["\s]*[:=]\s*["\s]*)([^"\s,;}]+)',
      caseSensitive: false,
    ),
    (match) => '${match.group(1)}${match.group(2)}[REDACTED]',
  );

  static bool _isSensitive(String name) => RegExp(
    r'authorization|api[-_ ]?key|token|cookie|password|secret',
    caseSensitive: false,
  ).hasMatch(name);
}
