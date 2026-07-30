import 'dart:async';
import 'package:devroute_ai_studio/core/agent_control/application/app_command.dart';
import 'package:devroute_ai_studio/core/agent_control/application/app_command_bus.dart';
import 'package:flutter_test/flutter_test.dart';

class _Command implements AppCommand<String> {
  const _Command(this.value);
  final String value;
  @override
  String get commandType => 'test';
}

class _Handler implements AppCommandHandler<_Command, String> {
  _Handler({this.gate, this.failure});
  final Completer<void>? gate;
  final Object? failure;
  int calls = 0;
  @override
  Future<String> handle(_Command command, AppCommandContext context) async {
    calls++;
    if (failure != null) throw failure!;
    if (gate != null) await gate!.future;
    context.cancellation.throwIfCancelled();
    return command.value;
  }
}

Future<void> _expectCategory(Future<Object?> future, String category) =>
    expectLater(
      future,
      throwsA(
        isA<AppCommandException>().having(
          (error) => error.category,
          'category',
          category,
        ),
      ),
    );

void main() {
  test('typed success, duplicate handler and unknown command', () async {
    final bus = AppCommandBus();
    final handler = _Handler();
    bus.register<_Command, String>(handler);
    expect(
      await bus.execute(
        const _Command('ok'),
        AppCommandContext(operationId: 'one', workspaceId: 'w'),
      ),
      'ok',
    );
    expect(
      () => bus.register<_Command, String>(_Handler()),
      throwsA(isA<AppCommandException>()),
    );
    await _expectCategory(
      bus.execute(
        _Other(),
        AppCommandContext(operationId: 'two', workspaceId: 'w'),
      ),
      'unknown_command',
    );
  });
  test(
    'pre-cancel prevents handler execution and cancellation is idempotent',
    () async {
      final token = CancellationToken()
        ..cancel()
        ..cancel();
      var observed = 0;
      token.cancelled.then((_) => observed++);
      await Future<void>.microtask(() {});
      expect(observed, 1);
      final handler = _Handler();
      final bus = AppCommandBus()..register<_Command, String>(handler);
      await _expectCategory(
        bus.execute(
          const _Command('x'),
          AppCommandContext(
            operationId: 'x',
            workspaceId: 'w',
            cancellation: token,
          ),
        ),
        'cancelled',
      );
      expect(handler.calls, 0);
    },
  );
  test(
    'active operation remains reserved until blocked handler settles',
    () async {
      final gate = Completer<void>();
      final handler = _Handler(gate: gate);
      final bus = AppCommandBus()..register<_Command, String>(handler);
      final token = CancellationToken();
      final first = bus.execute(
        const _Command('x'),
        AppCommandContext(
          operationId: 'same',
          workspaceId: 'w',
          cancellation: token,
        ),
      );
      await Future<void>.microtask(() {});
      await _expectCategory(
        bus.execute(
          const _Command('x'),
          AppCommandContext(operationId: 'same', workspaceId: 'w'),
        ),
        'duplicate_operation',
      );
      token.cancel();
      await _expectCategory(first, 'cancelled');
      await _expectCategory(
        bus.execute(
          const _Command('x'),
          AppCommandContext(operationId: 'same', workspaceId: 'w'),
        ),
        'duplicate_operation',
      );
      gate.complete();
      await Future<void>.microtask(() {});
      expect(
        await bus.execute(
          const _Command('done'),
          AppCommandContext(operationId: 'same', workspaceId: 'w'),
        ),
        'done',
      );
    },
  );
  test('timeout and late failure are terminal and do not escape', () async {
    final gate = Completer<void>();
    final handler = _Handler(gate: gate);
    final bus = AppCommandBus()..register<_Command, String>(handler);
    final errors = <Object>[];
    await runZonedGuarded(() async {
      await _expectCategory(
        bus.execute(
          const _Command('x'),
          AppCommandContext(operationId: 't', workspaceId: 'w'),
          timeout: Duration.zero,
        ),
        'timeout',
      );
      gate.complete();
      await Future<void>.microtask(() {});
    }, (error, _) => errors.add(error));
    expect(errors, isEmpty);
  });
  test(
    'synchronous and asynchronous handler failures classify safely',
    () async {
      final sync = AppCommandBus()
        ..register<_Command, String>(_Handler(failure: StateError('bad')));
      await _expectCategory(
        sync.execute(
          const _Command('x'),
          AppCommandContext(operationId: 's', workspaceId: 'w'),
        ),
        'handler_failure',
      );
      final gate = Completer<void>();
      final async = AppCommandBus()
        ..register<_Command, String>(_Handler(gate: gate));
      final pending = async.execute(
        const _Command('x'),
        AppCommandContext(operationId: 'a', workspaceId: 'w'),
      );
      gate.completeError(StateError('late'));
      await _expectCategory(pending, 'handler_failure');
    },
  );
}

class _Other implements AppCommand<void> {
  @override
  String get commandType => 'other';
}
