import 'package:collection/collection.dart';

class DocumentPosition {
  const DocumentPosition(this.path, this.offset);

  final List<int> path;
  final int offset;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocumentPosition && other.path == path && other.offset == offset;
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(path) ^ offset.hashCode;

  @override
  String toString() => 'DocumentPosition(path: $path, offset: $offset)';
}
