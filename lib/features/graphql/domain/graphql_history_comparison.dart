import 'dart:convert';

import '../../../core/diagnostics/history_comparison_service.dart';
import '../data/graphql_repository.dart';

class GraphqlHistoryComparison {
  const GraphqlHistoryComparison(this.changes);

  final List<ComparisonChange> changes;

  bool get isChanged => changes.isNotEmpty;

  List<ComparisonChange> get added =>
      changes.where((item) => item.before == null).toList(growable: false);

  List<ComparisonChange> get removed =>
      changes.where((item) => item.after == null).toList(growable: false);

  List<ComparisonChange> get changed => changes
      .where((item) => item.before != null && item.after != null)
      .toList(growable: false);
}

abstract final class GraphqlHistoryComparisonService {
  static GraphqlHistoryComparison compare(
    GraphqlHistoryEntry before,
    GraphqlHistoryEntry after,
  ) => GraphqlHistoryComparison(
    HistoryComparisonService.compareValues(before.summary, after.summary),
  );

  static String exportJson(
    GraphqlHistoryEntry before,
    GraphqlHistoryEntry after,
  ) {
    final comparison = compare(before, after);
    return const JsonEncoder.withIndent('  ').convert(<String, Object?>{
      'format': 'devroute.graphql-history-comparison',
      'version': 1,
      'before': _entryMetadata(before),
      'after': _entryMetadata(after),
      'changes': comparison.changes
          .map(
            (change) => <String, Object?>{
              'path': change.path,
              'kind': change.before == null
                  ? 'added'
                  : change.after == null
                  ? 'removed'
                  : 'changed',
              'before': _jsonSafe(change.before),
              'after': _jsonSafe(change.after),
            },
          )
          .toList(growable: false),
    });
  }

  static Map<String, Object?> _entryMetadata(GraphqlHistoryEntry entry) =>
      <String, Object?>{
        'id': entry.id,
        'draftId': entry.draftId,
        'workspaceId': entry.workspaceId,
        'operationType': entry.operationType.name,
        'createdAt': entry.createdAt.toUtc().toIso8601String(),
      };

  static Object? _jsonSafe(Object? value) {
    if (value == null || value is String || value is num || value is bool) {
      return value;
    }
    if (value is DateTime) return value.toUtc().toIso8601String();
    if (value is Map) {
      return value.map(
        (key, item) => MapEntry(key.toString(), _jsonSafe(item)),
      );
    }
    if (value is Iterable) {
      return value.map(_jsonSafe).toList(growable: false);
    }
    return value.toString();
  }
}
