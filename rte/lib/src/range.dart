import 'package:rte/src/position.dart';

class DocRange {
  const DocRange(this.start, this.end);

  final DocPosition start;
  final DocPosition end;

  bool get isCollapsed => start.path == end.path && start.offset == end.offset;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocRange && other.start == start && other.end == end;
  }

  @override
  int get hashCode => start.hashCode ^ end.hashCode;

  @override
  String toString() => 'DocRange(start: $start, end: $end)';
}
