import 'package:collection/collection.dart';

class DocPosition {
  const DocPosition(this.path, this.offset);

  final List<int> path;
  final int offset;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DocPosition && other.path == path && other.offset == offset;
  }

  @override
  int get hashCode => const DeepCollectionEquality().hash(path) ^ offset.hashCode;

  @override
  String toString() => 'DocPosition(path: $path, offset: $offset)';
}
