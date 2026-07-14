import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../../core/security/secret_masker.dart';
import '../../../shared/services/service_interfaces.dart';
import '../domain/realtime_models.dart';
import '../domain/sse_parser.dart';

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
    this.variables = const <String, String>{},
  });
  final SecureStorageService? _secureStorage;
  final Map<String, String> variables;
  Future<String> resolve(
    String value, {
    String? secretRef,
    bool isSecret = false,
  }) async {
    var result = value.replaceAllMapped(
      RegExp(r'{{\s*([^{}\s]+)\s*}}'),
      (match) => variables[match.group(1)] ?? match.group(0)!,
    );
    if (isSecret && secretRef != null && _secureStorage != null) {
      result = await _secureStorage.readSecret(secretRef) ?? '';
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
      RealtimeProtocolType.webSocket => _webSocket(uri, headers, config),
      RealtimeProtocolType.sse => _sse(uri, headers, config),
      RealtimeProtocolType.httpStream => _httpStream(uri, headers, config),
    };
  }

  Future<Uri> _uri(
    RealtimeSessionConfig config,
    RealtimeValueResolver resolver,
  ) async {
    final parsed = Uri.tryParse(await resolver.resolve(config.url));
    if (parsed == null || !parsed.hasScheme) {
      throw const FormatException('A complete URL is required.');
    }
    final query = <String, String>{...parsed.queryParameters};
    for (final item in config.queryParams.where((item) => item.enabled)) {
      query[await resolver.resolve(item.key)] = await resolver.resolve(
        item.value,
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
      headers[await resolver.resolve(header.key)] = await resolver.resolve(
        header.value,
        secretRef: header.secretRef,
        isSecret: header.isSecret,
      );
    }
    return headers;
  }

  Future<RealtimeTransportConnection> _webSocket(
    Uri uri,
    Map<String, String> headers,
    RealtimeSessionConfig config,
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
    return RealtimeTransportConnection(
      messages: socket.map((data) {
        if (data is List<int>) {
          return TransportMessage(
            type: RealtimePayloadType.binary,
            content: '[binary payload not retained]',
            bytes: Uint8List.fromList(data),
          );
        }
        final text = SecretMasker.redactText(data.toString());
        return TransportMessage(
          type: _looksJson(text)
              ? RealtimePayloadType.json
              : RealtimePayloadType.text,
          content: text,
        );
      }),
      send: (message) async => socket.add(message),
      close: () async =>
          socket.close(WebSocketStatus.normalClosure, 'Closed by user'),
    );
  }

  Future<RealtimeTransportConnection> _sse(
    Uri uri,
    Map<String, String> headers,
    RealtimeSessionConfig config,
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
          controller.add(
            TransportMessage(
              type: RealtimePayloadType.event,
              content: SecretMasker.redactText(event.data),
              eventName: event.event,
              eventId: event.id,
              retry: event.retry,
            ),
          );
          if (event.comment != null) {
            controller.add(
              TransportMessage(
                type: RealtimePayloadType.diagnostic,
                content: 'heartbeat: ${event.comment}',
              ),
            );
          }
        }
      },
      onError: controller.addError,
      onDone: () async {
        for (final event in parser.close()) {
          controller.add(
            TransportMessage(
              type: RealtimePayloadType.event,
              content: SecretMasker.redactText(event.data),
              eventName: event.event,
              eventId: event.id,
              retry: event.retry,
            ),
          );
        }
        await controller.close();
        client.close(force: true);
      },
    );
    return RealtimeTransportConnection(
      messages: controller.stream,
      close: () async {
        await subscription.cancel();
        await controller.close();
        client.close(force: true);
      },
    );
  }

  Future<RealtimeTransportConnection> _httpStream(
    Uri uri,
    Map<String, String> headers,
    RealtimeSessionConfig config,
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
      request.add(utf8.encode(body.content));
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
    late final StreamSubscription<List<int>> subscription;
    subscription = response.listen(
      (chunk) => controller.add(
        TransportMessage(
          type: RealtimePayloadType.chunk,
          content: SecretMasker.redactText(
            utf8.decode(chunk, allowMalformed: true),
          ),
        ),
      ),
      onError: controller.addError,
      onDone: () async {
        await controller.close();
        client.close(force: true);
      },
    );
    return RealtimeTransportConnection(
      messages: controller.stream,
      close: () async {
        await subscription.cancel();
        await controller.close();
        client.close(force: true);
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
