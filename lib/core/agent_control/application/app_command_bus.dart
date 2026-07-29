// ignore_for_file: curly_braces_in_flow_control_structures

import 'app_command.dart';

class AppCommandBus {
  final Map<Type, dynamic> _handlers = <Type, dynamic>{};
  final Map<String, CancellationToken> _operations =
      <String, CancellationToken>{};
  void register<T extends AppCommand<R>, R>(AppCommandHandler<T, R> handler) {
    if (_handlers.containsKey(T))
      throw const AppCommandException('duplicate_handler');
    _handlers[T] = handler;
  }

  Future<R> execute<T extends AppCommand<R>, R>(
    T command,
    AppCommandContext context, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (context.cancellation.isCancelled) {
      throw const AppCommandException('cancelled');
    }
    final handler = _handlers[T];
    if (handler == null) throw const AppCommandException('unknown_command');
    if (_operations.containsKey(context.operationId))
      throw const AppCommandException('duplicate_operation');
    _operations[context.operationId] = context.cancellation;
    try {
      final result = await (handler as AppCommandHandler<T, R>)
          .handle(command, context)
          .timeout(
            timeout,
            onTimeout: () => throw const AppCommandException('timeout'),
          );
      if (context.cancellation.isCancelled ||
          !identical(_operations[context.operationId], context.cancellation))
        throw const AppCommandException('stale_completion');
      return result;
    } on AppCommandException {
      rethrow;
    } catch (_) {
      throw const AppCommandException('handler_failure');
    } finally {
      _operations.remove(context.operationId);
    }
  }

  void cancel(String operationId) => _operations[operationId]?.cancel();
}
