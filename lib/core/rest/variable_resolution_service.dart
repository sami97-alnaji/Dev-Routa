import '../security/secret_masker.dart';

class VariableResolutionResult {
  const VariableResolutionResult({
    required this.value,
    this.unresolved = const <String>[],
    this.cycles = const <String>[],
    this.usedSecret = false,
  });
  final String value;
  final List<String> unresolved;
  final List<String> cycles;
  final bool usedSecret;
  bool get isValid => unresolved.isEmpty && cycles.isEmpty;
}

/// Resolves only supplied values. Secret values are supplied immediately before
/// execution and are never written to the local database or diagnostics.
class VariableResolutionService {
  static final _token = RegExp(r'{{\s*([A-Za-z0-9_.-]+)\s*}}');

  VariableResolutionResult resolve(
    String source, {
    Map<String, String> runtime = const <String, String>{},
    Map<String, String> request = const <String, String>{},
    Map<String, String> environment = const <String, String>{},
    Map<String, String> defaults = const <String, String>{},
    Set<String> secretKeys = const <String>{},
  }) {
    final values = <String, String>{
      ...defaults,
      ...environment,
      ...request,
      ...runtime,
    };
    final unresolved = <String>{};
    final cycles = <String>{};
    var usedSecret = false;

    String expand(String value, Set<String> trail) =>
        value.replaceAllMapped(_token, (match) {
          final key = match.group(1)!;
          final replacement = values[key];
          if (replacement == null) {
            unresolved.add(key);
            return match.group(0)!;
          }
          if (!trail.add(key)) {
            cycles.add(key);
            return match.group(0)!;
          }
          if (secretKeys.contains(key)) usedSecret = true;
          final expanded = expand(replacement, trail);
          trail.remove(key);
          return expanded;
        });

    return VariableResolutionResult(
      value: expand(source, <String>{}),
      unresolved: unresolved.toList()..sort(),
      cycles: cycles.toList()..sort(),
      usedSecret: usedSecret,
    );
  }

  String preview(VariableResolutionResult result) =>
      result.usedSecret ? SecretMasker.mask(result.value) : result.value;
}
