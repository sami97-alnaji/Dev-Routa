import '../domain/agent_models.dart';

typedef ToolExecutor =
    Future<Map<String, Object?>> Function(Map<String, Object?> input);
typedef ToolValidator = bool Function(Map<String, Object?> input);

class AgentToolDefinition {
  const AgentToolDefinition({
    required this.name,
    required this.version,
    required this.description,
    required this.risk,
    required this.permission,
    required this.requiresApproval,
    required this.timeout,
    required this.cancellable,
    required this.idempotency,
    required this.validator,
    required this.execute,
  });
  final String name;
  final String version;
  final String description;
  final AgentRisk risk;
  final AgentPermissionMode permission;
  final bool requiresApproval;
  final Duration timeout;
  final bool cancellable;
  final AgentIdempotency idempotency;
  final ToolValidator validator;
  final ToolExecutor execute;
}

class AgentToolRegistry {
  final Map<String, AgentToolDefinition> _tools =
      <String, AgentToolDefinition>{};
  void register(AgentToolDefinition tool) {
    if (_tools.containsKey(tool.name)) throw StateError('duplicate_tool');
    _tools[tool.name] = tool;
  }

  AgentToolDefinition require(String name) =>
      _tools[name] ?? (throw StateError('unknown_tool'));
  Iterable<AgentToolDefinition> get tools => _tools.values;
  static AgentToolRegistry foundation() {
    final registry = AgentToolRegistry();
    void add(
      String name,
      AgentRisk risk,
      AgentPermissionMode permission,
      bool approval,
      Map<String, Object?> output,
    ) => registry.register(
      AgentToolDefinition(
        name: name,
        version: '1',
        description: name,
        risk: risk,
        permission: permission,
        requiresApproval: approval,
        timeout: const Duration(seconds: 5),
        cancellable: true,
        idempotency: AgentIdempotency.idempotent,
        validator: (input) =>
            !input.containsKey('apiKey') && !input.containsKey('token'),
        execute: (_) async => output,
      ),
    );
    add(
      'app.capabilities',
      AgentRisk.readOnly,
      AgentPermissionMode.observe,
      false,
      <String, Object?>{'sanitized': true},
    );
    add(
      'workspace.list',
      AgentRisk.readOnly,
      AgentPermissionMode.observe,
      false,
      <String, Object?>{'workspaces': <Object?>[]},
    );
    add(
      'grpc.history.search',
      AgentRisk.readOnly,
      AgentPermissionMode.observe,
      false,
      <String, Object?>{'history': <Object?>[]},
    );
    add(
      'grpc.history.replayAsDraft',
      AgentRisk.draftChanging,
      AgentPermissionMode.draftEditor,
      false,
      <String, Object?>{'draft': 'created'},
    );
    add(
      'grpc.invoke.preview',
      AgentRisk.readOnly,
      AgentPermissionMode.observe,
      false,
      <String, Object?>{'preview': 'sanitized'},
    );
    add(
      'grpc.invoke.execute',
      AgentRisk.networkExecuting,
      AgentPermissionMode.approvedOperator,
      true,
      <String, Object?>{'blocked': true},
    );
    return registry;
  }
}
