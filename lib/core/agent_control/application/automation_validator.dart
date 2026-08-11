// ignore_for_file: curly_braces_in_flow_control_structures

import '../domain/agent_models.dart';
import 'agent_tool_registry.dart';

class AutomationValidator {
  List<String> validate(
    AutomationDefinition definition,
    AgentToolRegistry registry,
  ) {
    final errors = <String>[];
    if (!const {
      'manual',
      'schedulePlaceholder',
      'requestCompleted',
      'statusMatched',
      'streamEventMatched',
      'schemaChanged',
    }.contains(definition.trigger))
      errors.add('unknown_trigger');
    if (definition.limits.maximumSteps <= 0 ||
        definition.limits.maximumRequests <= 0 ||
        definition.limits.maximumDuration <= Duration.zero)
      errors.add('missing_limits');
    if (definition.steps.toSet().length != definition.steps.length)
      errors.add('cycle');
    for (final step in definition.steps) {
      try {
        final tool = registry.require(step);
        if (tool.risk == AgentRisk.destructive)
          errors.add('destructive_requires_policy');
        if (tool.risk == AgentRisk.networkExecuting &&
            definition.limits.allowProduction &&
            !definition.explicitProductionPolicy)
          errors.add('production_requires_policy');
      } catch (_) {
        errors.add('unknown_tool');
      }
    }
    if (definition.name.toLowerCase().contains('api_key') ||
        definition.name.toLowerCase().contains('token='))
      errors.add('embedded_secret');
    return errors;
  }
}
