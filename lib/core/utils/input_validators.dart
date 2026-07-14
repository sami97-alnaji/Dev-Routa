abstract final class InputValidators {
  static bool isHttpUrl(String value) => Uri.tryParse(value)?.hasScheme == true;
}
