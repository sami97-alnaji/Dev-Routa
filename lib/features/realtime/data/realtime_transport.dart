import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/security/secret_masker.dart';
import '../../../shared/models/api_models.dart';
import '../../../shared/services/service_interfaces.dart';
import '../domain/realtime_models.dart';
import '../domain/sse_parser.dart';
import '../domain/stream_decoders.dart';

class TransportMessage {
  const TransportMessage({
    required this.type,
    required this.content,
    this.bytes,
    this.eventName,
    this.eventId,
    this.retry,
  });
  final RealtimePayloadType type;
  final String content;
  final Uint8List? bytes;
  final String? eventName;
  final String? eventId;
  final int? retry;
}

class RealtimeTransportConnection {
  RealtimeTransportConnection({
    required this.messages,
    required this.close,
    this.send,
  });
  final Stream<TransportMessage> messages;
  final Future<void> Function() close;
  final Future<void> Function(Object message)? send;
}

/// Resolves references only inside the connection call. Its result is never
/// cached in configurations, drafts, event logs, or the local database.
class RealtimeValueResolver {
  RealtimeValueResolver(
    this._secureStorage, {
    Map<String, String> variables = const <String, String>{},
    Map<String, String> secretVariableRefs = const <String, String>{},
  }) : variables = Map<String, String>.of(variables),
       secretVariableRefs = Map<String, String>.of(secretVariableRefs);
  final SecureStorageService? _secureStorage;
  final Map<String, String> variables;
  final Map<String, String> secretVariableRefs;
  final Set<String> sensitiveValues = <String>{};
  RealtimeValueResolver fork() => RealtimeValueResolver(
    _secureStorage,
    variables: variables,
    secretVariableRefs: secretVariableRefs,
  );
  void clearSensitiveValues() => sensitiveValues.clear();
  void updateVariables(
    Map<String, String> values,
    Map<String, String> secretRefs,
  ) {
    variables
      ..clear()
      ..addAll(values);
    secretVariableRefs
      ..clear()
      ..addAll(secretRefs);
  }

  Future<String> resolve(
    String value, {
    String? secretRef,
    bool isSecret = false,
  }) async {
    var result = value;
    for (var pass = 0; pass < 10; pass++) {
      final expression = RegExp(r'{{\s*([^{}\s]+)\s*}}');
      final matches = expression.allMatches(result).toList();
      if (matches.isEmpty) break;
      final output = StringBuffer();
      var offset = 0;
      for (final match in matches) {
        output.write(result.substring(offset, match.start));
        final name = match.group(1)!;
        var replacement = variables[name];
        final reference = secretVariableRefs[name];
        if (replacement == null &&
            reference != null &&
            _secureStorage != null) {
          replacement = await _secureStorage.readSecret(reference);
          if (replacement != null && replacement.isNotEmpty) {
            sensitiveValues.add(replacement);
          }
        }
        output.write(replacement ?? match.group(0));
        offset = match.end;
      }
      output.write(result.substring(offset));
      final next = output.toString();
      if (next == result) break;
      result = next;
    }
    if (isSecret && secretRef != null && _secureStorage != null) {
      result = await _secureStorage.readSecret(secretRef) ?? '';
      if (result.isNotEmpty) sensitiveValues.add(result);
    }
    return result;
  }

  String redact(String value) {
    var result = SecretMasker.redactText(value);
    for (final sensitive in sensitiveValues.where((item) => item.isNotEmpty)) {
      result = result.replaceAll(sensitive, '[REDACTED]');
    }
    return result;
  }
}

class RealtimeTransport {
  RealtimeTransport({HttpClient Function()? clientFactory})
    : _clientFactory = clientFactory ?? HttpClient.new;
  final HttpClient Function() _clientFactory;

  Future<RealtimeTransportConnection> connect(
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    final uri = await _uri(config, resolver);
    final headers = await _headers(config, resolver);
    return switch (config.protocol) {
      RealtimeProtocolType.webSocket => _webSocket(
        uri,
        headers,
        config,
        resolver,
      ),
      RealtimeProtocolType.sse => _sse(uri, headers, config, resolver),
      RealtimeProtocolType.httpStream => _httpStream(
        uri,
        headers,
        config,
        resolver,
      ),
    };
  }

  Future<Uri> _uri(
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    final resolvedUrl = await resolver.resolve(config.url);
    if (resolvedUrl.contains(RegExp(r'{{\s*[^{}]+\s*}}'))) {
      throw const FormatException('The URL contains unresolved variables.');
    }
    final parsed = Uri.tryParse(resolvedUrl);
    if (parsed == null || !parsed.hasScheme) {
      throw const FormatException('A complete URL is required.');
    }
    final query = <String, String>{...parsed.queryParameters};
    for (final item in config.queryParams.where((item) => item.enabled)) {
      final key = await resolver.resolve(item.key);
      final value = await resolver.resolve(item.value);
      if ('$key$value'.contains(RegExp(r'{{\s*[^{}]+\s*}}'))) {
        throw const FormatException('A query parameter is unresolved.');
      }
      query[key] = value;
    }
    if (config.auth.type == AuthType.apiKeyQuery &&
        config.auth.apiKeyName.isNotEmpty) {
      query[config.auth.apiKeyName] = await resolver.resolve(
        '',
        secretRef: config.auth.apiKeySecretRef,
        isSecret: true,
      );
    }
    return parsed.replace(queryParameters: query);
  }

  Future<Map<String, String>> _headers(
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    final headers = <String, String>{};
    for (final header in config.headers.where((item) => item.enabled)) {
      final key = await resolver.resolve(header.key);
      final value = await resolver.resolve(
        header.value,
        secretRef: header.secretRef,
        isSecret: header.isSecret,
      );
      if (value.contains(RegExp(r'{{\s*[^{}]+\s*}}'))) {
        throw const FormatException('A header contains unresolved variables.');
      }
      if (header.isSecret && value.isEmpty) {
        throw FormatException('Secure value for header $key is unavailable.');
      }
      headers[key] = value;
    }
    final auth = config.auth;
    switch (auth.type) {
      case AuthType.none:
      case AuthType.apiKeyQuery:
        break;
      case AuthType.bearer:
        final token = await resolver.resolve(
          '',
          secretRef: auth.tokenSecretRef,
          isSecret: true,
        );
        if (token.isEmpty) {
          throw const FormatException('Bearer token is unavailable.');
        }
        headers[HttpHeaders.authorizationHeader] = 'Bearer $token';
        break;
      case AuthType.basic:
        final password = await resolver.resolve(
          '',
          secretRef: auth.passwordSecretRef,
          isSecret: true,
        );
        if (password.isEmpty) {
          throw const FormatException('Basic password is unavailable.');
        }
        headers[HttpHeaders.authorizationHeader] =
            'Basic ${base64Encode(utf8.encode('${auth.username}:$password'))}';
        break;
      case AuthType.apiKeyHeader:
        final value = await resolver.resolve(
          '',
          secretRef: auth.apiKeySecretRef,
          isSecret: true,
        );
        if (value.isEmpty) {
          throw const FormatException('API key is unavailable.');
        }
        if (auth.apiKeyName.isNotEmpty) headers[auth.apiKeyName] = value;
        break;
    }
    return headers;
  }

  Future<RealtimeTransportConnection> _webSocket(
    Uri uri,
    Map<String, String> headers,
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    if (uri.scheme != 'ws' && uri.scheme != 'wss') {
      throw const FormatException('WebSocket URLs must use ws or wss.');
    }
    final socket = await WebSocket.connect(
      uri.toString(),
      headers: headers,
      protocols: config.subprotocols,
      compression: CompressionOptions.compressionDefault,
    ).timeout(config.connectionTimeout);
    final controller = StreamController<TransportMessage>();
    late final StreamSubscription<dynamic> subscription;
    subscription = socket.listen(
      (data) {
        if (data is List<int>) {
          controller.add(
            TransportMessage(
              type: RealtimePayloadType.binary,
              content: '[binary payload not retained]',
              bytes: Uint8List.fromList(data),
            ),
          );
          return;
        }
        final text = resolver.redact(data.toString());
        controller.add(
          TransportMessage(
            type: _looksJson(text)
                ? RealtimePayloadType.json
                : RealtimePayloadType.text,
            content: text,
          ),
        );
      },
      onError: controller.addError,
      onDone: () async {
        final code = socket.closeCode;
        final reason = resolver.redact(socket.closeReason ?? '');
        if (code != null &&
            code != WebSocketStatus.normalClosure &&
            code != WebSocketStatus.goingAway) {
          controller.addError(
            WebSocketException('WebSocket closed with code $code: $reason'),
          );
        } else {
          controller.add(
            TransportMessage(
              type: RealtimePayloadType.diagnostic,
              content:
                  'WebSocket closed normally${reason.isEmpty ? '' : ': $reason'}',
            ),
          );
        }
        await controller.close();
        resolver.clearSensitiveValues();
      },
    );
    return RealtimeTransportConnection(
      messages: controller.stream,
      send: (message) async => socket.add(message),
      close: () async {
        await subscription.cancel();
        await socket.close(WebSocketStatus.normalClosure, 'Closed by user');
        if (!controller.isClosed) await controller.close();
        resolver.clearSensitiveValues();
      },
    );
  }

  Future<RealtimeTransportConnection> _sse(
    Uri uri,
    Map<String, String> headers,
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw const FormatException('SSE URLs must use http or https.');
    }
    final client = _clientFactory();
    final request = await client.getUrl(uri).timeout(config.connectionTimeout);
    headers.forEach(request.headers.set);
    request.headers.set(HttpHeaders.acceptHeader, 'text/event-stream');
    if (config.lastEventId != null && config.lastEventId!.isNotEmpty) {
      request.headers.set('Last-Event-ID', config.lastEventId!);
    }
    final response = await request.close().timeout(config.connectionTimeout);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      client.close(force: true);
      throw HttpException(
        'SSE server returned ${response.statusCode}.',
        uri: uri,
      );
    }
    final parser = SseParser();
    final controller = StreamController<TransportMessage>();
    late final StreamSubscription<List<int>> subscription;
    subscription = response.listen(
      (chunk) {
        for (final event in parser.add(chunk)) {
          if (event.data.isNotEmpty) {
            controller.add(
              TransportMessage(
                type: RealtimePayloadType.event,
                content: resolver.redact(event.data),
                eventName: event.event,
                eventId: event.id,
                retry: event.retry,
              ),
            );
          }
          if (event.comment != null) {
            controller.add(
              TransportMessage(
                type: RealtimePayloadType.diagnostic,
                content: 'heartbeat: ${event.comment}',
              ),
            );
          }
          if (event.diagnostic != null) {
            controller.add(
              TransportMessage(
                type: RealtimePayloadType.diagnostic,
                content: resolver.redact(event.diagnostic!),
              ),
            );
          }
        }
      },
      onError: controller.addError,
      onDone: () async {
        for (final event in parser.close()) {
          if (event.data.isNotEmpty) {
            controller.add(
              TransportMessage(
                type: RealtimePayloadType.event,
                content: resolver.redact(event.data),
                eventName: event.event,
                eventId: event.id,
                retry: event.retry,
              ),
            );
          }
          if (event.comment != null) {
            controller.add(
              TransportMessage(
                type: RealtimePayloadType.diagnostic,
                content: 'heartbeat: ${event.comment}',
              ),
            );
          }
          if (event.diagnostic != null) {
            controller.add(
              TransportMessage(
                type: RealtimePayloadType.diagnostic,
                content: resolver.redact(event.diagnostic!),
              ),
            );
          }
        }
        await controller.close();
        client.close(force: true);
        resolver.clearSensitiveValues();
      },
    );
    return RealtimeTransportConnection(
      messages: controller.stream,
      close: () async {
        await subscription.cancel();
        await controller.close();
        client.close(force: true);
        resolver.clearSensitiveValues();
      },
    );
  }

  Future<RealtimeTransportConnection> _httpStream(
    Uri uri,
    Map<String, String> headers,
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      throw const FormatException(
        'HTTP streaming URLs must use http or https.',
      );
    }
    final client = _clientFactory();
    final request = await client
        .openUrl(config.method.name.toUpperCase(), uri)
        .timeout(config.connectionTimeout);
    headers.forEach(request.headers.set);
    final body = config.body;
    if (body != null && body.content.isNotEmpty) {
      request.headers.contentType = ContentType.parse(
        body.contentType ?? 'text/plain; charset=utf-8',
      );
      final resolvedBody = await resolver.resolve(body.content);
      if (resolvedBody.contains(RegExp(r'{{\s*[^{}]+\s*}}'))) {
        throw const FormatException('The streaming body is unresolved.');
      }
      request.add(utf8.encode(resolvedBody));
    }
    final response = await request.close().timeout(config.connectionTimeout);
    if (response.statusCode >= 400) {
      client.close(force: true);
      throw HttpException(
        'Streaming server returned ${response.statusCode}.',
        uri: uri,
      );
    }
    final controller = StreamController<TransportMessage>();
    final decoder = IncrementalUtf8Decoder();
    final ndjson = NdjsonDecoder();
    var pendingLine = '';
    void emitText(String text, {bool closing = false}) {
      if (text.isEmpty && !closing) return;
      if (config.streamMode == HttpStreamMode.raw) {
        if (text.isNotEmpty) {
          controller.add(
            TransportMessage(
              type: RealtimePayloadType.chunk,
              content: resolver.redact(text),
            ),
          );
        }
        return;
      }
      if (config.streamMode == HttpStreamMode.ndjson) {
        final records = <NdjsonRecord>[
          ...ndjson.addText(text),
          if (closing) ...ndjson.close(),
        ];
        for (final record in records) {
          controller.add(
            TransportMessage(
              type: record.isValid
                  ? RealtimePayloadType.ndjson
                  : RealtimePayloadType.diagnostic,
              content: resolver.redact(record.raw),
            ),
          );
        }
        return;
      }
      final lines = ('$pendingLine$text').split('\n');
      pendingLine = closing ? '' : lines.removeLast();
      if (closing && lines.isNotEmpty && lines.last.isEmpty) lines.removeLast();
      for (final line in lines) {
        controller.add(
          TransportMessage(
            type: RealtimePayloadType.text,
            content: resolver.redact(line.replaceFirst(RegExp(r'\r$'), '')),
          ),
        );
      }
      if (closing && pendingLine.isNotEmpty) {
        controller.add(
          TransportMessage(
            type: RealtimePayloadType.text,
            content: resolver.redact(pendingLine),
          ),
        );
        pendingLine = '';
      }
    }

    late final StreamSubscription<List<int>> subscription;
    subscription = response.listen(
      (chunk) => emitText(decoder.add(chunk)),
      onError: controller.addError,
      onDone: () async {
        emitText(decoder.close(), closing: true);
        await controller.close();
        client.close(force: true);
        resolver.clearSensitiveValues();
      },
    );
    return RealtimeTransportConnection(
      messages: controller.stream,
      close: () async {
        await subscription.cancel();
        if (!controller.isClosed) await controller.close();
        client.close(force: true);
        resolver.clearSensitiveValues();
      },
    );
  }

  static bool _looksJson(String value) {
    try {
      jsonDecode(value);
      return true;
    } catch (_) {
      return false;
    }
  }
}
