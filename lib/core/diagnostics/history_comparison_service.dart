import 'dart:convert';

import '../../features/realtime/data/realtime_repository.dart';

class ComparisonChange {
  const ComparisonChange(this.path, this.before, this.after);
  final String path;
  final Object? before;
  final Object? after;
}

abstract final class HistoryComparisonService {
  static List<ComparisonChange> compareJsonText(String before, String after) {
    try {
      return compareValues(jsonDecode(before), jsonDecode(after));
    } catch (_) {
      return before == after
          ? const <ComparisonChange>[]
          : <ComparisonChange>[ComparisonChange(r'$', before, after)];
    }
  }

  static List<ComparisonChange> compareValues(
    Object? before,
    Object? after, [
    String path = r'$',
  ]) {
    if (before is Map && after is Map) {
      final changes = <ComparisonChange>[];
      final keys = <Object>{...before.keys, ...after.keys};
      for (final key in keys) {
        changes.addAll(
          compareValues(before[key], after[key], '$path.${key.toString()}'),
        );
      }
      return changes;
    }
    if (before is List && after is List) {
      final changes = <ComparisonChange>[];
      final length = before.length > after.length
          ? before.length
          : after.length;
      for (var index = 0; index < length; index++) {
        changes.addAll(
          compareValues(
            index < before.length ? before[index] : null,
            index < after.length ? after[index] : null,
            '$path[$index]',
          ),
        );
      }
      return changes;
    }
    return before == after
        ? const <ComparisonChange>[]
        : <ComparisonChange>[ComparisonChange(path, before, after)];
  }

  static List<ComparisonChange> compareRealtime(
    RealtimeHistoryEntry before,
    RealtimeHistoryEntry after,
  ) => compareValues(
    <String, Object?>{
      'protocol': before.protocol.name,
      'status': before.status,
      ...before.summary,
    },
    <String, Object?>{
      'protocol': after.protocol.name,
      'status': after.status,
      ...after.summary,
    },
  );
}
