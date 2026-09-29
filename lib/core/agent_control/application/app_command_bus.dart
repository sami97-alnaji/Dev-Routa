// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';

import 'app_command.dart';

class AppCommandBus {
  final Map<Type, dynamic> _handlers = <Type, dynamic>{};
  final Map<String, _Operation> _operations = <String, _Operation>{};
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
    final operation = _Operation(context.operationId, context.cancellation);
    _operations[context.operationId] = operation;
    late Future<R> handlerFuture;
    var settled = false;
    try {
      handlerFuture = (handler as AppCommandHandler<T, R>).handle(
        command,
        context,
      );
      handlerFuture.whenComplete(() => settled = true).ignore();
      final winner = await Future.any<Object?>(<Future<Object?>>[
        handlerFuture,
        context.cancellation.cancelled.then<Object?>(
          (_) => const AppCommandException('cancelled'),
        ),
        Future<Object?>.delayed(
          timeout,
          () => const AppCommandException('timeout'),
        ),
      ]);
      if (winner is AppCommandException) {
        context.cancellation.cancel();
        throw winner;
      }
      if (context.cancellation.isCancelled ||
          !identical(_operations[context.operationId], operation))
        throw const AppCommandException('stale_completion');
      return winner as R;
    } on AppCommandException {
      rethrow;
    } catch (_) {
      throw const AppCommandException('handler_failure');
    } finally {
      void cleanup() {
        if (identical(_operations[context.operationId], operation)) {
          _operations.remove(context.operationId);
        }
      }

      if (settled) {
        cleanup();
      } else {
        handlerFuture.whenComplete(cleanup).ignore();
      }
    }
  }

  void cancel(String operationId) => _operations[operationId]?.token.cancel();
}

class _Operation {
  _Operation(this.operationId, this.token);
  final String operationId;
  final CancellationToken token;
  final Completer<void> terminal = Completer<void>();
}
