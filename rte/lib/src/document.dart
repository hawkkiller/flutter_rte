import 'package:rte/src/node.dart';
import 'package:rte/src/document_range.dart';

class Document {
  const Document(this.root, {this.selection});

  final RootNode root;
  final DocumentRange? selection;

  Document copyWith({RootNode? root, DocumentRange? selection}) {
    return Document(root ?? this.root, selection: selection ?? this.selection);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Document &&
        other.root == root &&
        other.selection == selection;
  }

  @override
  int get hashCode => root.hashCode ^ selection.hashCode;

  @override
  String toString() => 'Document(root: $root, selection: $selection)';
}
