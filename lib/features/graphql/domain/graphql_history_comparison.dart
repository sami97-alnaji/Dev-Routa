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
}
