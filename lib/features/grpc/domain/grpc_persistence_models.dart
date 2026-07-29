import 'dart:collection';
import 'dart:typed_data';

enum GrpcDescriptorSourceType { manualProto, descriptorSet, reflection }

enum GrpcPersistedInvocationKind {
  unary,
  serverStreaming,
  clientStreaming,
  bidirectionalStreaming,
}

enum GrpcHistoryOutcome {
  success,
  grpcFailure,
  transportFailure,
  deadline,
  cancelled,
  codecFailure,
  reflectionFailure,
}

enum GrpcStoredEventDirection { sent, received, system }

class GrpcPersistenceFailure implements Exception {
  const GrpcPersistenceFailure(this.category, this.message);

  final String category;
  final String message;

  @override
  String toString() => 'GrpcPersistenceFailure($category)';
}

Map<String, Object?> immutableJson(Map<String, Object?> source) =>
    UnmodifiableMapView<String, Object?>(_copyMap(source));

List<String> immutableStrings(Iterable<String> source) =>
    List<String>.unmodifiable(source);

Map<String, Object?> _copyMap(Map<String, Object?> source) =>
    source.map((key, value) => MapEntry(key, _copyJson(value)));

Object? _copyJson(Object? value) => switch (value) {
  Map<String, Object?> map => _copyMap(map),
  Map map => map.map((key, item) => MapEntry(key.toString(), _copyJson(item))),
  List list => list.map(_copyJson).toList(growable: false),
  _ => value,
};

class GrpcDescriptorSnapshot {
  GrpcDescriptorSnapshot({
    required this.id,
    required this.workspaceId,
    required this.fingerprint,
    required this.sourceType,
    required this.displayName,
    required Uint8List descriptorBytes,
    required this.fileCount,
    required this.serviceCount,
    required this.createdAt,
    required this.lastUsedAt,
    this.sourceIdentity,
  }) : descriptorBytes = Uint8List.fromList(descriptorBytes) {
    if (descriptorBytes.isEmpty || descriptorBytes.length > 16 * 1024 * 1024) {
      throw const GrpcPersistenceFailure(
        'descriptorSize',
        'Descriptor bytes are outside the persisted limit.',
      );
    }
  }

  final String id;
  final String workspaceId;
  final String fingerprint;
  final GrpcDescriptorSourceType sourceType;
  final String displayName;
  final String? sourceIdentity;
  final Uint8List descriptorBytes;
  final int fileCount;
  final int serviceCount;
  final DateTime createdAt;
  final DateTime lastUsedAt;

  @override
  String toString() =>
      'GrpcDescriptorSnapshot(id: $id, source: ${sourceType.name})';
}

class GrpcSavedRequest {
  GrpcSavedRequest({
    required this.id,
    required this.workspaceId,
    required this.name,
    required this.serviceFullName,
    required this.methodName,
    required this.methodPath,
    required this.invocationKind,
    required Map<String, Object?> endpoint,
    required Map<String, Object?> request,
    required Map<String, Object?> metadata,
    required Iterable<String> certificateReferences,
    required this.sortOrder,
    required this.revision,
    required this.createdAt,
    required this.updatedAt,
    this.collectionId,
    this.folderId,
    this.descriptorSnapshotId,
  }) : endpoint = immutableJson(endpoint),
       request = immutableJson(request),
       metadata = immutableJson(metadata),
       certificateReferences = immutableStrings(certificateReferences) {
    if (name.trim().isEmpty || name.length > 200) {
      throw const GrpcPersistenceFailure('name', 'Invalid saved request name.');
    }
  }

  final String id;
  final String workspaceId;
  final String? collectionId;
  final String? folderId;
  final String? descriptorSnapshotId;
  final String name;
  final int sortOrder;
  final String serviceFullName;
  final String methodName;
  final String methodPath;
  final GrpcPersistedInvocationKind invocationKind;
  final Map<String, Object?> endpoint;
  final Map<String, Object?> request;
  final Map<String, Object?> metadata;
  final List<String> certificateReferences;
  final int revision;
  final DateTime createdAt;
  final DateTime updatedAt;

  @override
  String toString() => 'GrpcSavedRequest(id: $id, name: $name)';
}

class GrpcDraft {
  GrpcDraft({
    required this.id,
    required this.workspaceId,
    required this.title,
    required Map<String, Object?> methodIdentity,
    required Map<String, Object?> endpoint,
    required Map<String, Object?> request,
    required Map<String, Object?> metadata,
    required Iterable<String> certificateReferences,
    required this.revision,
    required this.tabOrder,
    required this.dirty,
    required this.createdAt,
    required this.updatedAt,
    required this.lastOpenedAt,
    this.sourceSavedRequestId,
    this.descriptorSnapshotId,
  }) : methodIdentity = immutableJson(methodIdentity),
       endpoint = immutableJson(endpoint),
       request = immutableJson(request),
       metadata = immutableJson(metadata),
       certificateReferences = immutableStrings(certificateReferences);

  final String id;
  final String workspaceId;
  final String? sourceSavedRequestId;
  final String? descriptorSnapshotId;
  final String title;
  final Map<String, Object?> methodIdentity;
  final Map<String, Object?> endpoint;
  final Map<String, Object?> request;
  final Map<String, Object?> metadata;
  final List<String> certificateReferences;
  final int revision;
  final int tabOrder;
  final bool dirty;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime lastOpenedAt;

  @override
  String toString() => 'GrpcDraft(id: $id, title: $title)';
}

class GrpcStoredStreamEvent {
  GrpcStoredStreamEvent({
    required this.id,
    required this.sessionHistoryId,
    required this.sequenceNumber,
    required this.direction,
    required this.category,
    required this.occurredAt,
    required this.rawByteCount,
    Map<String, Object?>? decodedPayload,
    Uint8List? retainedRawBytes,
    this.statusCode,
    this.statusText,
    this.decodeFailureCategory,
  }) : decodedPayload = decodedPayload == null
           ? null
           : immutableJson(decodedPayload),
       retainedRawBytes = retainedRawBytes == null
           ? null
           : Uint8List.fromList(retainedRawBytes) {
    if (sequenceNumber < 0 || rawByteCount < 0) {
      throw const GrpcPersistenceFailure(
        'eventBounds',
        'Invalid event bounds.',
      );
    }
  }

  final String id;
  final String sessionHistoryId;
  final int sequenceNumber;
  final GrpcStoredEventDirection direction;
  final String category;
  final DateTime occurredAt;
  final Map<String, Object?>? decodedPayload;
  final int rawByteCount;
  final Uint8List? retainedRawBytes;
  final int? statusCode;
  final String? statusText;
  final String? decodeFailureCategory;

  @override
  String toString() =>
      'GrpcStoredStreamEvent(sequence: $sequenceNumber, direction: ${direction.name})';
}

class GrpcInvocationHistory {
  GrpcInvocationHistory({
    required this.id,
    required this.workspaceId,
    required this.invocationKind,
    required this.startedAt,
    required Map<String, Object?> endpoint,
    required Map<String, Object?> methodIdentity,
    required Map<String, Object?> request,
    required Map<String, Object?> requestMetadata,
    required Map<String, Object?> responseHeaders,
    required Map<String, Object?> responseTrailers,
    required this.requestByteCount,
    required this.responseByteCount,
    required this.outcome,
    required this.droppedEventCount,
    required this.terminalState,
    required this.createdAt,
    Map<String, Object?>? response,
    this.savedRequestId,
    this.descriptorSnapshotId,
    this.completedAt,
    this.durationMicroseconds,
    this.statusCode,
    this.statusName,
    this.statusMessage,
    this.diagnosticCategory,
  }) : endpoint = immutableJson(endpoint),
       methodIdentity = immutableJson(methodIdentity),
       request = immutableJson(request),
       requestMetadata = immutableJson(requestMetadata),
       response = response == null ? null : immutableJson(response),
       responseHeaders = immutableJson(responseHeaders),
       responseTrailers = immutableJson(responseTrailers);

  final String id;
  final String workspaceId;
  final String? savedRequestId;
  final String? descriptorSnapshotId;
  final GrpcPersistedInvocationKind invocationKind;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int? durationMicroseconds;
  final Map<String, Object?> endpoint;
  final Map<String, Object?> methodIdentity;
  final Map<String, Object?> request;
  final Map<String, Object?> requestMetadata;
  final Map<String, Object?>? response;
  final Map<String, Object?> responseHeaders;
  final Map<String, Object?> responseTrailers;
  final int? statusCode;
  final String? statusName;
  final String? statusMessage;
  final int requestByteCount;
  final int responseByteCount;
  final GrpcHistoryOutcome outcome;
  final String? diagnosticCategory;
  final int droppedEventCount;
  final String terminalState;
  final DateTime createdAt;

  bool get isFinalized => completedAt != null;

  @override
  String toString() =>
      'GrpcInvocationHistory(id: $id, outcome: ${outcome.name})';
}

class GrpcHistoryFilter {
  const GrpcHistoryFilter({
    this.query,
    this.invocationKind,
    this.outcome,
    this.statusCode,
    this.savedRequestId,
    this.descriptorSnapshotId,
    this.from,
    this.to,
  });

  final String? query;
  final GrpcPersistedInvocationKind? invocationKind;
  final GrpcHistoryOutcome? outcome;
  final int? statusCode;
  final String? savedRequestId;
  final String? descriptorSnapshotId;
  final DateTime? from;
  final DateTime? to;
}

class GrpcRetentionPolicy {
  const GrpcRetentionPolicy({
    required this.maximumAge,
    required this.maximumCount,
    required this.maximumRetainedBytes,
  });

  final Duration maximumAge;
  final int maximumCount;
  final int maximumRetainedBytes;
}

class GrpcComparisonChange {
  const GrpcComparisonChange({
    required this.path,
    required this.kind,
    this.before,
    this.after,
  });

  final String path;
  final String kind;
  final Object? before;
  final Object? after;
}

class GrpcUnaryComparison {
  const GrpcUnaryComparison({
    required this.changes,
    required this.durationDeltaMicroseconds,
    required this.requestByteDelta,
    required this.responseByteDelta,
  });

  final List<GrpcComparisonChange> changes;
  final int durationDeltaMicroseconds;
  final int requestByteDelta;
  final int responseByteDelta;
}

class GrpcStreamingComparison {
  const GrpcStreamingComparison({
    required this.summaryChanges,
    required this.eventChanges,
    required this.onlyInLeft,
    required this.onlyInRight,
    required this.retentionWarning,
  });

  final List<GrpcComparisonChange> summaryChanges;
  final List<GrpcComparisonChange> eventChanges;
  final List<int> onlyInLeft;
  final List<int> onlyInRight;
  final bool retentionWarning;
}
