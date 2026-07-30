// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:convert';

import 'agent_process_runner.dart';

enum AgentProcessPolicyRejection {
  invalidOperationId, executableNotAbsolute, executableNotAllowed,
  shellLauncherRejected, shellModeArgumentRejected, workingDirectoryNotAbsolute,
  workingDirectoryEscape, environmentKeyNotAllowed, sensitiveEnvironmentKey,
  invalidTimeout, timeoutExceedsPolicy, invalidOutputLimit,
  outputLimitExceedsPolicy, tooManyArguments, argumentTooLarge,
  tooManyEnvironmentEntries, environmentValueTooLarge,
}

class AgentProcessPolicyDecision {
  const AgentProcessPolicyDecision.allowed() : rejection = null;
  const AgentProcessPolicyDecision.rejected(this.rejection);
  final AgentProcessPolicyRejection? rejection;
  bool get allowed => rejection == null;
}

class AgentProcessPolicy {
  const AgentProcessPolicy({
    required this.allowedExecutablePaths, required this.allowedWorkspaceRoots,
    required this.allowedEnvironmentKeys, this.maximumArguments = 32,
    this.maximumArgumentBytes = 4096, this.maximumEnvironmentEntries = 8,
    this.maximumEnvironmentValueBytes = 4096,
    this.maximumTimeout = const Duration(minutes: 1),
    this.absoluteMaximumStdoutBytes = 65536,
    this.absoluteMaximumStderrBytes = 65536,
  });
  final Set<String> allowedExecutablePaths, allowedWorkspaceRoots, allowedEnvironmentKeys;
  final int maximumArguments, maximumArgumentBytes, maximumEnvironmentEntries, maximumEnvironmentValueBytes;
  final Duration maximumTimeout;
  final int absoluteMaximumStdoutBytes, absoluteMaximumStderrBytes;
}

class AgentProcessPolicyValidator {
  const AgentProcessPolicyValidator(this.policy);
  final AgentProcessPolicy policy;
  AgentProcessPolicyDecision validate(AgentProcessRequest request) {
    if (request.operationId.trim().isEmpty) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.invalidOperationId);
    if (request.timeout <= Duration.zero) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.invalidTimeout);
    if (request.timeout > policy.maximumTimeout) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.timeoutExceedsPolicy);
    if (request.maximumStdoutBytes < 0 || request.maximumStderrBytes < 0) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.invalidOutputLimit);
    if (request.maximumStdoutBytes > policy.absoluteMaximumStdoutBytes || request.maximumStderrBytes > policy.absoluteMaximumStderrBytes) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.outputLimitExceedsPolicy);
    if (request.arguments.length > policy.maximumArguments) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.tooManyArguments);
    if (request.arguments.any((a) => utf8.encode(a).length > policy.maximumArgumentBytes)) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.argumentTooLarge);
    if (request.requestedEnvironment.length > policy.maximumEnvironmentEntries) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.tooManyEnvironmentEntries);
    for (final entry in request.requestedEnvironment.entries) {
      final key = entry.key.toUpperCase();
      if (_sensitive(key)) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.sensitiveEnvironmentKey);
      if (!policy.allowedEnvironmentKeys.map((e) => e.toUpperCase()).contains(key)) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.environmentKeyNotAllowed);
      if (utf8.encode(entry.value).length > policy.maximumEnvironmentValueBytes) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.environmentValueTooLarge);
    }
    final executable = canonical(request.executablePath);
    if (!_absolute(executable)) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.executableNotAbsolute);
    if (_shell(executable)) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.shellLauncherRejected);
    if (!policy.allowedExecutablePaths.map(canonical).contains(executable)) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.executableNotAllowed);
    if (request.arguments.any((a) => const {'/c','/k','-c','--command','-command','-encodedcommand','--eval','-e'}.contains(a.toLowerCase()))) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.shellModeArgumentRejected);
    final directory = canonical(request.workingDirectory);
    if (!_absolute(directory)) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.workingDirectoryNotAbsolute);
    if (!policy.allowedWorkspaceRoots.map(canonical).any((root) => directory == root || directory.startsWith('$root\\'))) return const AgentProcessPolicyDecision.rejected(AgentProcessPolicyRejection.workingDirectoryEscape);
    return const AgentProcessPolicyDecision.allowed();
  }
  static bool _absolute(String p) => RegExp(r'^[a-z]:\\', caseSensitive: false).hasMatch(p);
  static bool _shell(String p) => const {'cmd.exe','powershell.exe','pwsh.exe','bash','bash.exe','sh','sh.exe','wsl.exe','cscript.exe','wscript.exe','mshta.exe','rundll32.exe'}.contains(p.split('\\').last);
  static bool _sensitive(String key) => const ['TOKEN','SECRET','PASSWORD','PASSWD','API_KEY','APIKEY','AUTH','COOKIE','SESSION','CREDENTIAL','PRIVATE_KEY','ACCESS_KEY','OPENAI','ANTHROPIC','GOOGLE','GEMINI','AZURE','AWS','GITHUB','NPM'].any(key.contains);
  static String canonical(String path) {
    final parts = <String>[];
    for (final p in path.replaceAll('/', '\\').split('\\')) { if (p.isEmpty && parts.isEmpty) continue; if (p == '.' || p.isEmpty) continue; if (p == '..') { if (parts.length > 1) parts.removeLast(); else parts.add('..'); } else { parts.add(p); } }
    return parts.join('\\').toLowerCase();
  }
}
