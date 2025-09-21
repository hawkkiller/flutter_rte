import 'package:collection/collection.dart';
import 'package:rte_core/src/core/document_range.dart';
import 'package:rte_core/src/core/node.dart';

class Document {
  const Document({
    this.selection,
    this.nodes = const [],
  });

  final DocumentRange? selection;
  final List<BlockNode> nodes;

  Document copyWith({
    DocumentRange? selection,
    List<BlockNode>? nodes,
  }) {
    return Document(
      selection: selection ?? this.selection,
      nodes: nodes ?? this.nodes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Document &&
        other.selection == selection &&
        const DeepCollectionEquality().equals(other.nodes, nodes);
  }

  @override
  int get hashCode => selection.hashCode ^ const DeepCollectionEquality().hash(nodes);
}
