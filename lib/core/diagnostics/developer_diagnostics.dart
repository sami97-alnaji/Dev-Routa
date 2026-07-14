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
    return diagnostics;
  }

  static String _statusExplanation(int status) => switch (status) {
    401 || 403 => 'Check authentication and permissions.',
    404 => 'Check the URL and request method.',
    408 || 504 => 'The server or gateway timed out.',
    >= 500 => 'The server reported an internal failure.',
    _ => 'Inspect the response details and request configuration.',
  };
}
