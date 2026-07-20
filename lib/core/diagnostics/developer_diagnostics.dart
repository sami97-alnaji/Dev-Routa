import '../../features/realtime/domain/realtime_models.dart';
import '../../shared/models/api_models.dart';

enum DiagnosticKind { observed, suggestion }

class DeveloperDiagnostic {
  const DeveloperDiagnostic({
    required this.kind,
    required this.title,
    required this.detail,
  });
  final DiagnosticKind kind;
  final String title;
  final String detail;
}

abstract final class DeveloperDiagnostics {
  static List<DeveloperDiagnostic> forRequest(
    ApiRequestModel request,
    ApiResponseModel? response,
  ) {
    final diagnostics = <DeveloperDiagnostic>[];
    if (request.url.contains('{{')) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.observed,
          title: 'Unresolved variable',
          detail: 'The URL contains an unresolved {{variable}} reference.',
        ),
      );
    }
    if (Uri.tryParse(request.url)?.hasScheme != true) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.observed,
          title: 'Invalid URL',
          detail: 'The request URL does not contain a complete scheme.',
        ),
      );
    }
    if (request.headers.any(
      (header) =>
          _sensitiveName(header.key) &&
          !header.isSecret &&
          header.value.isNotEmpty,
    )) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.suggestion,
          title: 'Secret exposure risk',
          detail:
              'A sensitive header uses a plain value instead of secure storage.',
        ),
      );
    }
    if (request.auth.type != AuthType.none &&
        request.headers.any(
          (header) => header.key.toLowerCase() == 'authorization',
        )) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.suggestion,
          title: 'Duplicate authentication',
          detail:
              'Use either the auth configuration or an Authorization header to avoid conflicting credentials.',
        ),
      );
    }
    if (response != null && response.durationMs > 3000) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.observed,
          title: 'Slow response',
          detail: 'The response took more than 3 seconds.',
        ),
      );
    }
    if (response != null && response.sizeBytes > 1024 * 1024) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.observed,
          title: 'Large response',
          detail: 'The response exceeded the safe preview threshold.',
        ),
      );
    }
    if (response != null) {
      final contentType = response.headers.entries
          .where((item) => item.key.toLowerCase() == 'content-type')
          .map((item) => item.value.toLowerCase())
          .firstOrNull;
      if (contentType?.contains('json') == true &&
          !_looksLikeJson(response.body)) {
        diagnostics.add(
          const DeveloperDiagnostic(
            kind: DiagnosticKind.observed,
            title: 'Content-Type mismatch',
            detail: 'The response claims JSON but the body is not valid JSON.',
          ),
        );
      }
      if (response.errorCategory != null) {
        diagnostics.add(
          DeveloperDiagnostic(
            kind: DiagnosticKind.observed,
            title: 'Transport category',
            detail: response.errorCategory!,
          ),
        );
      }
    }
    if (response != null &&
        response.statusCode != null &&
        response.statusCode! >= 400) {
      diagnostics.add(
        DeveloperDiagnostic(
          kind: DiagnosticKind.suggestion,
          title: 'HTTP ${response.statusCode}',
          detail: _statusExplanation(response.statusCode!),
        ),
      );
    }
    return diagnostics;
  }

  static List<DeveloperDiagnostic> forRealtime(RealtimeSessionState state) {
    final diagnostics = <DeveloperDiagnostic>[];
    final config = state.config;
    if (config != null &&
        (config.url.contains('{{') ||
            config.headers.any((item) => item.value.contains('{{')))) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.observed,
          title: 'Unresolved realtime variable',
          detail: 'The URL or a header still contains a variable expression.',
        ),
      );
    }
    if (config != null &&
        config.headers.any(
          (item) =>
              _sensitiveName(item.key) &&
              !item.isSecret &&
              item.value.isNotEmpty,
        )) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.suggestion,
          title: 'Secret exposure risk',
          detail: 'Store sensitive realtime headers by secure reference.',
        ),
      );
    }
    if (state.failure != null) {
      diagnostics.add(
        DeveloperDiagnostic(
          kind: DiagnosticKind.observed,
          title: 'Connection ${state.failure!.category}',
          detail: state.failure!.message,
        ),
      );
    }
    if (state.metrics.reconnectAttempts > 0) {
      diagnostics.add(
        DeveloperDiagnostic(
          kind: DiagnosticKind.observed,
          title: 'Reconnect attempts',
          detail:
              '${state.metrics.reconnectAttempts} bounded reconnect attempt(s) occurred.',
        ),
      );
    }
    if (state.config?.protocol == RealtimeProtocolType.sse &&
        state.messages
            .where(
              (message) =>
                  message.payloadType == RealtimePayloadType.diagnostic,
            )
            .isEmpty) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.suggestion,
          title: 'No heartbeat observed',
          detail:
              'The stream has not sent an SSE comment heartbeat. This may be normal.',
        ),
      );
    }
    if (state.config?.protocol == RealtimeProtocolType.sse &&
        state.status == RealtimeConnectionStatus.connected &&
        state.metrics.duration != null &&
        state.metrics.duration! > const Duration(seconds: 30) &&
        state.messages.isEmpty) {
      diagnostics.add(
        const DeveloperDiagnostic(
          kind: DiagnosticKind.suggestion,
          title: 'SSE stream may be stalled',
          detail: 'No events or heartbeat comments arrived for 30 seconds.',
        ),
      );
    }
    final malformed = state.messages.where(
      (message) =>
          message.payloadType == RealtimePayloadType.diagnostic &&
          message.content.toLowerCase().contains('not-json'),
    );
    if (malformed.isNotEmpty) {
      diagnostics.add(
        DeveloperDiagnostic(
          kind: DiagnosticKind.observed,
          title: 'Malformed NDJSON',
          detail: '${malformed.length} malformed line(s) were observed.',
        ),
      );
    }
    return diagnostics;
  }

  static String _statusExplanation(int status) => switch (status) {
    401 || 403 => 'Check authentication and permissions.',
    404 => 'Check the URL and request method.',
    408 || 504 => 'The server or gateway timed out.',
    >= 500 => 'The server reported an internal failure.',
    _ => 'Inspect the response details and request configuration.',
  };

  static bool _looksLikeJson(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return false;
    return (trimmed.startsWith('{') && trimmed.endsWith('}')) ||
        (trimmed.startsWith('[') && trimmed.endsWith(']'));
  }

  static bool _sensitiveName(String value) => RegExp(
    r'authorization|api[-_ ]?key|token|cookie|password',
    caseSensitive: false,
  ).hasMatch(value);
}
