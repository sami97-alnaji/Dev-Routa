import 'dart:io';

import 'package:path/path.dart' as path;
import 'package:devroute_ai_studio/core/agent_control/data/codex_subscription_adapter.dart';
import 'package:devroute_ai_studio/core/agent_control/domain/agent_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'isolated Codex runtime writes only the minimal DevRoute profile',
    () async {
      final root = await Directory.systemTemp.createTemp('codex-home-test-');
      addTearDown(() => root.delete(recursive: true));
      final runtime = CodexIsolatedRuntime(homeDirectory: root);

      await runtime.ensure();
      final config = await File(
        '${root.path}${Platform.pathSeparator}config.toml',
      ).readAsString();

      expect(config, CodexIsolatedRuntime.configToml);
      expect(config, isNot(contains('mcp_servers')));
      expect(config, isNot(contains('plugins')));
      expect(config, isNot(contains('skills')));
    },
  );

  test('isolated runtime readiness requires a dedicated ChatGPT login', () {
    const readiness = CodexRuntimeReadiness(
      isolatedProfileReady: true,
      authentication: AgentAuthenticationStatus.unauthenticated,
      mcpServerCount: null,
      noMcpStartupEvents: true,
    );

    expect(readiness.canRun, isFalse);
    expect(readiness.effectiveFailureCategory, 'isolated_login_required');
  });

  test(
    'default isolated profile uses a platform-specific DevRoute directory',
    () {
      final profile = CodexIsolatedRuntime().homeDirectory.path;

      expect(path.isAbsolute(profile), isTrue);
      expect(path.basename(profile), 'codex-home');
      expect(path.basename(path.dirname(profile)), 'DevRoute');
    },
  );

  test(
    'isolated child environment has no inherited user profile variables',
    () async {
      final root = await Directory.systemTemp.createTemp(
        'codex-environment-test-',
      );
      addTearDown(() => root.delete(recursive: true));
      final environment = await CodexIsolatedRuntime(
        homeDirectory: root,
      ).environment();

      expect(
        environment.keys,
        unorderedEquals(<String>[
          'CODEX_HOME',
          'HOME',
          'TEMP',
          'TMP',
          'TMPDIR',
          if (Platform.isWindows) 'SystemRoot',
        ]),
      );
      expect(environment['CODEX_HOME'], root.path);
      expect(environment['HOME'], root.path);
      expect(environment['TEMP'], Directory.systemTemp.path);
      expect(environment['TMP'], Directory.systemTemp.path);
      expect(environment['TMPDIR'], Directory.systemTemp.path);
      expect(environment.containsKey('SystemRoot'), Platform.isWindows);
      expect(environment.containsKey('APPDATA'), isFalse);
      expect(environment.containsKey('USERPROFILE'), isFalse);
      expect(environment.keys.any((key) => key.startsWith('OPENAI_')), isFalse);
    },
  );
}
