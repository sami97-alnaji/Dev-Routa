import '../domain/agent_models.dart';
import 'dart:convert';

enum AgentToolAvailability { available, unavailableInFoundation }

abstract interface class AgentToolCodec<T> {
  T decode(Map<String, Object?> input);
  Map<String, Object?> encode(T value);
}

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
    required this.maximumInputBytes,
    required this.maximumOutputBytes,
    required this.allowedInputFields,
    required this.rejectUnknownFields,
    required this.availability,
    this.productionRestriction = true,
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
  final int maximumInputBytes;
  final int maximumOutputBytes;
  final Set<String> allowedInputFields;
  final bool rejectUnknownFields;
  final AgentToolAvailability availability;
  final bool productionRestriction;
  bool accepts(Map<String, Object?> input) =>
      validator(input) &&
      utf8.encode(jsonEncode(input)).length <= maximumInputBytes &&
      (!rejectUnknownFields || input.keys.every(allowedInputFields.contains));
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
      Map<String, Object?> output, {
      AgentIdempotency idempotency = AgentIdempotency.idempotent,
      AgentToolAvailability availability = AgentToolAvailability.available,
    }) => registry.register(
      AgentToolDefinition(
        name: name,
        version: '1',
        description: name,
        risk: risk,
        permission: permission,
        requiresApproval: approval,
        timeout: const Duration(seconds: 5),
        cancellable: true,
        idempotency: idempotency,
        validator: (input) =>
            !input.containsKey('apiKey') && !input.containsKey('token'),
        execute: (_) async => output,
        maximumInputBytes: 16384,
        maximumOutputBytes: 65536,
        allowedInputFields: const <String>{},
        rejectUnknownFields: true,
        availability: availability,
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
      idempotency: AgentIdempotency.nonIdempotent,
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
      <String, Object?>{},
      availability: AgentToolAvailability.unavailableInFoundation,
    );
    return registry;
  }
}
