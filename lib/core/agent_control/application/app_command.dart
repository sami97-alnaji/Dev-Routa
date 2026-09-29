import 'dart:async';

abstract interface class AppCommand<TResult> {
  String get commandType;
}

abstract interface class AppCommandHandler<
  TCommand extends AppCommand<TResult>,
  TResult
> {
  Future<TResult> handle(TCommand command, AppCommandContext context);
}

class AppCommandContext {
  AppCommandContext({
    required this.operationId,
    required this.workspaceId,
    this.environmentId,
    CancellationToken? cancellation,
  }) : cancellation = cancellation ?? CancellationToken();
  final String operationId;
  final String workspaceId;
  final String? environmentId;
  final CancellationToken cancellation;
}

class CancellationToken {
  bool _cancelled = false;
  final Completer<void> _completion = Completer<void>();
  bool get isCancelled => _cancelled;
  Future<void> get cancelled => _completion.future;
  void cancel() {
    if (_cancelled) return;
    _cancelled = true;
    _completion.complete();
  }

  void throwIfCancelled() {
    if (_cancelled) throw const AppCommandException('cancelled');
  }
}

class AppCommandException implements Exception {
  const AppCommandException(this.category);
  final String category;
  @override
  String toString() => category;
}
