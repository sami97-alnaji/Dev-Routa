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

  static bool _isSensitive(String name) => RegExp(
    r'authorization|api[-_ ]?key|token|cookie|password',
    caseSensitive: false,
  ).hasMatch(name);
}
