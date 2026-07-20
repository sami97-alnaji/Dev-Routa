import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ai/consent_ai_service.dart';
import '../../../core/security/secret_masker.dart';
import '../../../shared/services/service_interfaces.dart';
import '../data/realtime_repository.dart';
import '../data/realtime_transport.dart';
import '../domain/realtime_models.dart';

class RealtimeSessionCubit extends Cubit<RealtimeSessionState> {
  RealtimeSessionCubit(
    this._transport,
    this._repository, {
    SecureStorageService? secureStorage,
    Map<String, String> variables = const <String, String>{},
  }) : _resolver = RealtimeValueResolver(secureStorage, variables: variables),
       super(const RealtimeSessionState());
  RealtimeSessionCubit._sibling(
    this._transport,
    this._repository,
    this._resolver,
  ) : super(const RealtimeSessionState());
  final RealtimeTransport _transport;
  final RealtimeRepository _repository;
  final RealtimeValueResolver _resolver;
  StreamSubscription<TransportMessage>? _subscription;
  RealtimeTransportConnection? _connection;
  var _generation = 0;
  var _manualClose = false;
  final List<TransportMessage> _pendingStreamMessages = <TransportMessage>[];
  Timer? _flushTimer;

  Future<void> connect(RealtimeSessionConfig config) =>
      _connect(config, reconnectAttempt: 0);

  Future<void> _connect(
    RealtimeSessionConfig config, {
    required int reconnectAttempt,
  }) async {
    if (state.status == RealtimeConnectionStatus.connecting ||
        state.status == RealtimeConnectionStatus.connected) {
      return;
    }
    _manualClose = false;
    final generation = ++_generation;
    emit(
      RealtimeSessionState(
        status: RealtimeConnectionStatus.connecting,
        config: config,
        metrics: RealtimeMetrics(
          startedAt: reconnectAttempt == 0
              ? DateTime.now()
              : state.metrics.startedAt ?? DateTime.now(),
          bytesIn: reconnectAttempt == 0 ? 0 : state.metrics.bytesIn,
          bytesOut: reconnectAttempt == 0 ? 0 : state.metrics.bytesOut,
          reconnectAttempts: reconnectAttempt,
        ),
        isDirty: false,
      ),
    );
    try {
      final connection = await _transport.connect(config, _resolver);
      if (isClosed || generation != _generation) {
        await connection.close();
        return;
      }
      _connection = connection;
      emit(
        state.copyWith(
          status: RealtimeConnectionStatus.connected,
          clearFailure: true,
        ),
      );
      _subscription = connection.messages.listen(
        _receive,
        onError: (Object error, StackTrace trace) => _failed(error),
        onDone: _completed,
      );
    } catch (error) {
      if (!isClosed && generation == _generation) _failed(error);
    }
  }

  Future<void> disconnect() async {
    _manualClose = true;
    ++_generation;
    await _subscription?.cancel();
    _subscription = null;
    await _connection?.close();
    _connection = null;
    _flushPendingStreamMessages();
    if (!isClosed && state.config != null) {
      emit(
        state.copyWith(
          status: RealtimeConnectionStatus.disconnected,
          metrics: state.metrics.copyWith(endedAt: DateTime.now()),
        ),
      );
      await _persist();
    }
  }

  Future<void> cancel() async {
    _manualClose = true;
    ++_generation;
    await _subscription?.cancel();
    _subscription = null;
    await _connection?.close();
    _connection = null;
    _flushPendingStreamMessages();
    if (!isClosed) {
      emit(
        state.copyWith(
          status: RealtimeConnectionStatus.cancelled,
          metrics: state.metrics.copyWith(endedAt: DateTime.now()),
        ),
      );
      await _persist();
    }
  }

  Future<void> reconnect() async {
    final config = state.config;
    if (config == null) return;
    await disconnect();
    await connect(config);
  }

  void updateConfig(RealtimeSessionConfig config) =>
      emit(state.copyWith(config: config, isDirty: true));

  void updateEnvironmentVariables(
    Map<String, String> values,
    Map<String, String> secretRefs,
  ) => _resolver.updateVariables(values, secretRefs);

  Future<void> saveDraft() async {
    if (state.config != null) {
      await _repository.saveDraft(state.config!);
    }
  }

  Future<void> saveConfiguration() async {
    if (state.config != null) {
      await _repository.saveConfiguration(state.config!);
      emit(state.copyWith(isDirty: false));
    }
  }

  Future<List<RealtimeSessionConfig>> configurations(String workspaceId) =>
      _repository.configurations(workspaceId);
  Future<List<RealtimeSessionConfig>> drafts(String workspaceId) =>
      _repository.drafts(workspaceId);
  Future<void> deleteConfiguration(String id) =>
      _repository.deleteConfiguration(id);
  Future<void> deleteDraft(String configurationId) =>
      _repository.deleteDraft(configurationId);
  Future<List<RealtimeHistoryEntry>> history({RealtimeHistoryFilter? filter}) =>
      _repository.history(filter: filter);
  Future<void> updateHistoryMetadata(
    String id, {
    bool? pinned,
    List<String>? tags,
    String? notes,
  }) =>
      _repository.updateMetadata(id, pinned: pinned, tags: tags, notes: notes);
  Future<void> deleteHistory(String id) => _repository.deleteHistory(id);
  Future<void> clearHistory({String? workspaceId}) =>
      _repository.clearHistory(workspaceId: workspaceId);
  Future<RealtimeSessionConfig?> reopenHistory(String id) =>
      _repository.reopen(id);
  Future<void> applyRetention({required int maximumCount, int? days}) =>
      _repository.retain(
        maximumCount: maximumCount,
        olderThan: days == null
            ? null
            : DateTime.now().subtract(Duration(days: days)),
      );
  Future<({int days, int maximumCount})> retention(String workspaceId) =>
      _repository.retention(workspaceId);
  Future<void> saveRetention(
    String workspaceId, {
    required int days,
    required int maximumCount,
  }) => _repository.saveRetention(
    workspaceId,
    days: days,
    maximumCount: maximumCount,
  );
  Future<AiConsentOptions> aiPreferences() => _repository.aiPreferences();
  Future<void> saveAiPreferences(AiConsentOptions options) =>
      _repository.saveAiPreferences(options);

  RealtimeSessionCubit createSibling() =>
      RealtimeSessionCubit._sibling(_transport, _repository, _resolver.fork());

  Future<void> sendText(String value) => _send(value, RealtimePayloadType.text);
  Future<void> sendJson(String value) async {
    try {
      final pretty = const JsonEncoder.withIndent(
        '  ',
      ).convert(jsonDecode(value));
      await _send(pretty, RealtimePayloadType.json);
    } catch (_) {
      throw const FormatException('The outgoing message is not valid JSON.');
    }
  }

  Future<void> sendBinary(Uint8List bytes) =>
      _send(bytes, RealtimePayloadType.binary);

  Future<void> _send(Object value, RealtimePayloadType type) async {
    if (!state.canSend || _connection?.send == null) {
      throw StateError('Only an active WebSocket session can send messages.');
    }
    await _connection!.send!(value);
    final content = type == RealtimePayloadType.binary
        ? '[binary payload not retained]'
        : SecretMasker.redactText(value.toString());
    _append(
      RealtimeMessage(
        sequence: state.messages.length + 1,
        direction: RealtimeMessageDirection.outbound,
        payloadType: type,
        timestamp: DateTime.now(),
        content: content,
        bytes: type == RealtimePayloadType.binary ? null : null,
      ),
    );
    emit(
      state.copyWith(
        metrics: state.metrics.copyWith(
          bytesOut:
              state.metrics.bytesOut +
              (value is Uint8List ? value.length : value.toString().length),
        ),
      ),
    );
  }

  void clearMessages() =>
      emit(state.copyWith(messages: const <RealtimeMessage>[]));

  void _receive(TransportMessage message) {
    if (state.config?.protocol == RealtimeProtocolType.httpStream) {
      _pendingStreamMessages.add(message);
      _flushTimer ??= Timer(
        const Duration(milliseconds: 16),
        _flushPendingStreamMessages,
      );
      return;
    }
    _receiveNow(message);
  }

  void _flushPendingStreamMessages() {
    _flushTimer?.cancel();
    _flushTimer = null;
    if (isClosed || _pendingStreamMessages.isEmpty) return;
    final messages = List<TransportMessage>.of(_pendingStreamMessages);
    _pendingStreamMessages.clear();
    for (final message in messages) {
      _receiveNow(message);
    }
  }

  void _receiveNow(TransportMessage message) {
    final body = message.type == RealtimePayloadType.binary
        ? '[binary payload not retained]'
        : SecretMasker.redactText(message.content);
    _append(
      RealtimeMessage(
        sequence: state.messages.length + 1,
        direction: RealtimeMessageDirection.inbound,
        payloadType: message.type,
        timestamp: DateTime.now(),
        content: body,
        bytes: null,
        eventName: message.eventName,
        eventId: message.eventId,
        retry: message.retry,
      ),
    );
    if ((message.eventId != null || message.retry != null) &&
        state.config != null) {
      final currentPolicy = state.config!.reconnectPolicy;
      emit(
        state.copyWith(
          config: state.config!.copyWith(
            lastEventId: message.eventId,
            reconnectPolicy: message.retry == null
                ? currentPolicy
                : ReconnectPolicy(
                    enabled: currentPolicy.enabled,
                    maxAttempts: currentPolicy.maxAttempts,
                    initialDelay: Duration(milliseconds: message.retry!),
                    maxDelay: currentPolicy.maxDelay,
                  ),
          ),
          metrics: state.metrics.copyWith(
            bytesIn: state.metrics.bytesIn + message.content.length,
          ),
        ),
      );
    } else {
      emit(
        state.copyWith(
          metrics: state.metrics.copyWith(
            bytesIn:
                state.metrics.bytesIn +
                (message.bytes?.length ?? message.content.length),
          ),
        ),
      );
    }
  }

  void _append(RealtimeMessage message) {
    final maximum = state.config?.maxEvents ?? 500;
    final messages = <RealtimeMessage>[...state.messages, message];
    if (messages.length > maximum) {
      final dropped = messages.length - maximum;
      messages.removeRange(0, messages.length - maximum);
      emit(
        state.copyWith(
          messages: messages,
          droppedMessages: state.droppedMessages + dropped,
        ),
      );
      return;
    }
    emit(state.copyWith(messages: messages));
  }

  Future<void> _completed() async {
    if (isClosed || _manualClose) {
      return;
    }
    _flushPendingStreamMessages();
    emit(
      state.copyWith(
        status: RealtimeConnectionStatus.completed,
        metrics: state.metrics.copyWith(endedAt: DateTime.now()),
      ),
    );
    await _persist();
  }

  Future<void> _failed(Object error) async {
    if (isClosed || _manualClose) {
      return;
    }
    _flushPendingStreamMessages();
    final failure = _failure(error);
    _append(
      RealtimeMessage(
        sequence: state.messages.length + 1,
        direction: RealtimeMessageDirection.system,
        payloadType: RealtimePayloadType.diagnostic,
        timestamp: DateTime.now(),
        content: failure.message,
      ),
    );
    final policy = state.config?.reconnectPolicy;
    final attempt = state.metrics.reconnectAttempts;
    if (policy != null && policy.enabled && attempt < policy.maxAttempts) {
      emit(
        state.copyWith(
          status: RealtimeConnectionStatus.reconnecting,
          failure: failure,
          metrics: state.metrics.copyWith(reconnectAttempts: attempt + 1),
        ),
      );
      final generation = _generation;
      await Future<void>.delayed(policy.delayFor(attempt));
      if (!isClosed &&
          !_manualClose &&
          generation == _generation &&
          state.config != null) {
        await _connect(state.config!, reconnectAttempt: attempt + 1);
      }
      return;
    }
    emit(
      state.copyWith(
        status: RealtimeConnectionStatus.failed,
        failure: failure,
        metrics: state.metrics.copyWith(endedAt: DateTime.now()),
      ),
    );
    await _persist();
  }

  RealtimeFailure _failure(Object error) {
    final text = error.toString();
    final category = text.contains('Timeout')
        ? 'timeout'
        : text.contains('Socket') || text.contains('HttpException')
        ? 'network'
        : text.contains('FormatException')
        ? 'configuration'
        : 'unknown';
    return RealtimeFailure(category, SecretMasker.redactText(text));
  }

  Future<void> _persist() async {
    if (state.config != null) {
      await _repository.saveSession(
        RealtimeSessionSnapshot(config: state.config!, state: state),
      );
    }
  }

  @override
  Future<void> close() async {
    _flushTimer?.cancel();
    await disconnect();
    return super.close();
  }
}
