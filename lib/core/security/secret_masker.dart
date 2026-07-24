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

  /// Redacts sensitive map keys and the exact runtime secrets used by a
  /// connection without retaining or exposing the original values.
  static Object? redactStructured(
    Object? value, {
    Iterable<String> runtimeSecrets = const <String>[],
    String? key,
  }) {
    if (key != null && _isSensitive(key)) return '[REDACTED]';
    if (value is Map) {
      return value.map(
        (itemKey, itemValue) => MapEntry(
          itemKey.toString(),
          redactStructured(
            itemValue,
            runtimeSecrets: runtimeSecrets,
            key: itemKey.toString(),
          ),
        ),
      );
    }
    if (value is Iterable) {
      return value
          .map((item) => redactStructured(item, runtimeSecrets: runtimeSecrets))
          .toList(growable: false);
    }
    if (value is! String) return value;
    var sanitized = value;
    final ordered = runtimeSecrets.where((item) => item.isNotEmpty).toList()
      ..sort((a, b) => b.length.compareTo(a.length));
    for (final secret in ordered) {
      sanitized = sanitized.replaceAll(secret, '[REDACTED]');
    }
    return redactText(sanitized);
  }

  static bool _isSensitive(String name) => RegExp(
    r'authorization|api[-_ ]?key|token|cookie|password|secret',
    caseSensitive: false,
  ).hasMatch(name);
}
