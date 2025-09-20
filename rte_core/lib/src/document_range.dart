import 'package:rte_core/src/document_position.dart';

class DocumentRange {
  const DocumentRange(this.start, this.end);

  final DocumentPosition start;
  final DocumentPosition end;

  bool get isCollapsed => start.path == end.path && start.offset == end.offset;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocumentRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() => 'DocumentRange(start: $start, end: $end)';
}
