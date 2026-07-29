// ignore_for_file: curly_braces_in_flow_control_structures

import '../application/app_command.dart';

class AgentProcessRequest {
  const AgentProcessRequest({
    required this.executablePath,
    required this.arguments,
    required this.workingDirectory,
    required this.allowedEnvironmentKeys,
    required this.timeout,
    required this.maximumStdoutBytes,
    required this.maximumStderrBytes,
  });
  final String executablePath;
  final List<String> arguments;
  final String workingDirectory;
  final Set<String> allowedEnvironmentKeys;
  final Duration timeout;
  final int maximumStdoutBytes;
  final int maximumStderrBytes;
}

class AgentProcessResult {
  const AgentProcessResult({
    required this.exitCode,
    required this.stdout,
    required this.stderr,
  });
  final int exitCode;
  final String stdout;
  final String stderr;
}

abstract interface class AgentProcessRunner {
  Future<AgentProcessResult> run(AgentProcessRequest request);
  Future<void> cancel(String operationId);
}

class FakeAgentProcessRunner implements AgentProcessRunner {
  AgentProcessRequest? lastRequest;
  @override
  Future<AgentProcessResult> run(AgentProcessRequest request) async {
    if (!request.executablePath.startsWith('official://') ||
        !request.workingDirectory.startsWith('workspace://'))
      throw const AppCommandException('process_policy_rejected');
    lastRequest = request;
    return AgentProcessResult(
      exitCode: 0,
      stdout: 'ok'.substring(0, request.maximumStdoutBytes.clamp(0, 2)),
      stderr: '',
    );
  }

  @override
  Future<void> cancel(String operationId) async {}
}
