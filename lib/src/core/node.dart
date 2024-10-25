/// Base class for all nodes in the editor
abstract class RTENode {
  RTENode({
    required this.id,
    required this.type,
    this.parent,
  });

  /// Unique identifier for the node
  final String id;

  /// Type of the node
  final String type;

  /// Parent node
  RTENode? parent;

  /// Clone this node with optional overrides
  RTENode clone();

  /// Get the length of this node's content
  int get length;

  /// Get text content of this node and its children
  String toPlainText();

  /// Check if this node can contain other nodes
  bool get canContainChildren => true;

  /// Convert node to JSON for serialization
  Map<String, Object?> toJson();
}

abstract class RTEElementNode extends RTENode {
  RTEElementNode({
    required super.id,
    required super.type,
    super.parent,
    List<RTENode>? children,
  }) : children = children ?? [];

  List<RTENode> children;

  /// Insert a child node at specified index
  void insertChild(RTENode child, int index) {
    children.insert(index, child);
    child.parent = this;
  }

  /// Remove a child node
  bool removeChild(RTENode child) {
    final removed = children.remove(child);
    if (removed) {
      child.parent = null;
    }

    return removed;
  }

  /// Find node at given path
  RTENode? getNodeAtPath(List<int> path) {
    if (path.isEmpty) return this;

    if (path[0] >= children.length) return null;

    final child = children[path[0]];

    if (child is RTEElementNode) {
      return child.getNodeAtPath(path.sublist(1));
    }

    return null;
  }

  /// Get path to descendant node
  List<int>? getPathToDescendant(RTENode descendant) {
    for (var i = 0; i < children.length; i++) {
      if (children[i].id == descendant.id) {
        return [i];
      }

      final child = children[i];

      if (child is RTEElementNode) {
        final path = child.getPathToDescendant(descendant);
        if (path != null) {
          return [i, ...path];
        }

        continue;
      }
    }

    return null;
  }
}

/// Root document node
class RTEDocumentNode extends RTEElementNode {
  RTEDocumentNode({
    super.children,
  }) : super(type: 'document', id: 'root');

  /// Create an empty document node
  RTEDocumentNode.empty() : this(children: []);

  @override
  int get length => children.fold(0, (sum, child) => sum + child.length);

  @override
  String toPlainText() => children.map((child) => child.toPlainText()).join('\n');

  @override
  RTEDocumentNode clone({
    RTENode? parent,
    List<RTENode>? children,
  }) {
    return RTEDocumentNode(
      children: children ?? List.of(this.children),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
        'type': type,
        'id': id,
        'children': children.map((child) => child.toJson()).toList(),
      };
}

/// Paragraph node containing text content
class RTEParagraphNode extends RTEElementNode {
  RTEParagraphNode({
    required super.id,
    super.children,
  }) : super(type: 'paragraph');

  @override
  int get length => children.fold(0, (sum, child) => sum + child.length);

  @override
  String toPlainText() => children.map((child) => child.toPlainText()).join('');

  @override
  RTEParagraphNode clone({
    String? id,
    RTENode? parent,
    List<RTENode>? children,
  }) {
    return RTEParagraphNode(
      id: id ?? this.id,
      children: children ?? List.of(this.children),
    );
  }

  @override
  Map<String, Object?> toJson() => {
        'type': type,
        'id': id,
        'children': children.map((child) => child.toJson()).toList(),
      };
}

/// Text node containing plain text content
class RTETextNode extends RTENode {
  RTETextNode({
    required super.id,
    required this.text,
  }) : super(type: 'text');

  /// Text content
  String text;

  @override
  bool get canContainChildren => false;

  @override
  int get length => text.length;

  @override
  String toPlainText() => text;

  @override
  RTETextNode clone({
    String? id,
    RTENode? parent,
    List<RTENode>? children,
    String? text,
  }) {
    return RTETextNode(
      id: id ?? this.id,
      text: text ?? this.text,
    );
  }

  @override
  Map<String, Object?> toJson() => {
        'type': type,
        'id': id,
        'text': text,
      };
}
