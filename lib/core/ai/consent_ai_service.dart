import '../security/secret_masker.dart';

class AiConsentOptions {
  const AiConsentOptions({
    this.granted = false,
    this.includeBodies = false,
    this.includeHeaders = false,
    this.includeHistory = false,
    this.includeEvents = false,
  });
  final bool granted;
  final bool includeBodies;
  final bool includeHeaders;
  final bool includeHistory;
  final bool includeEvents;
}

class AiPayloadPreview {
  const AiPayloadPreview(this.payload);
  final Map<String, Object?> payload;
}

abstract interface class ExternalAiProvider {
  Future<String> analyze(AiPayloadPreview preview);
}

class FakeAiProvider implements ExternalAiProvider {
  @override
  Future<String> analyze(AiPayloadPreview preview) async =>
      'Fake provider: reviewed ${preview.payload.keys.length} redacted fields.';
}

abstract final class ConsentAiService {
  static AiPayloadPreview preview({
    required AiConsentOptions options,
    required Map<String, Object?> source,
  }) {
    if (!options.granted) {
      return const AiPayloadPreview(<String, Object?>{
        'consent': false,
        'message':
            'External AI is disabled until you explicitly approve a redacted preview.',
      });
    }
    final result = <String, Object?>{'consent': true};
    source.forEach((key, value) {
      final include =
          (key == 'body' && options.includeBodies) ||
          (key == 'headers' && options.includeHeaders) ||
          (key == 'history' && options.includeHistory) ||
          (key == 'events' && options.includeEvents) ||
          !<String>{'body', 'headers', 'history', 'events'}.contains(key);
      if (include) {
        result[key] = SecretMasker.redactText(value.toString());
      }
    });
    return AiPayloadPreview(result);
  }
}
