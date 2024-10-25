/// Base class for all nodes in the editor
abstract class RTENode {
  RTENode({
    required this.id,
    required this.type,
    this.parent,
    List<RTENode> children = const [],
  }) : children = List.of(children) {
    for (final child in children) {
      adoptChildWithoutAddingToList(child);
    }
  }

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

  final List<RTENode> children;

  /// Insert a child node at specified index
  void insertChild(RTENode child, int index) {
    adoptChildWithoutAddingToList(child);

    children.insert(index, child);
  }

  /// Become the parent of a node, without adding it to children
  void adoptChildWithoutAddingToList(RTENode node) {
    if (node.parent != null) {
      node.parent!.removeChild(node);
    }

    node.parent = this;
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

    return children[path[0]].getNodeAtPath(path.sublist(1));
  }

  /// Get path to descendant node
  List<int>? getPathToDescendant(RTENode descendant) {
    for (var i = 0; i < children.length; i++) {
      if (children[i].id == descendant.id) {
        return [i];
      }

      final childPath = children[i].getPathToDescendant(descendant);
      if (childPath != null) {
        return [i, ...childPath];
      }
    }

    return null;
  }

  List<int> getPathToRoot() {
    final path = <int>[];
    RTENode node = this;

    while (node.parent != null) {
      final index = node.parent!.children.indexWhere(
        (child) => child.id == node.id,
      );
      path.insert(0, index);
      node = node.parent!;
    }

    return path;
  }

  /// Convert node to JSON for serialization
  Map<String, Object?> toJson();
}

/// Root document node
class RTEDocumentNode extends RTENode {
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
class RTEParagraphNode extends RTENode {
  RTEParagraphNode({
    required super.id,
    List<RTETextNode> children = const [],
  })  : children = List.of(children),
        super(type: 'paragraph') {
    for (final child in children) {
      adoptChildWithoutAddingToList(child);
    }
  }

  @override
  int get length => children.fold(0, (sum, child) => sum + child.length);

  @override
  String toPlainText() => children.map((child) => child.toPlainText()).join('');

  @override
  // ignore: overridden_fields
  final List<RTETextNode> children;

  @override
  RTEParagraphNode clone({
    String? id,
    RTENode? parent,
    List<RTETextNode>? children,
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

class TextFormatRTE {
  const TextFormatRTE({
    this.bold = false,
    this.italic = false,
    this.underline = false,
    this.strikethrough = false,
    this.subscript = false,
    this.superscript = false,
  });

  final bool bold;
  final bool italic;
  final bool underline;
  final bool strikethrough;
  final bool subscript;
  final bool superscript;
}

/// Text node containing plain text content
class RTETextNode extends RTENode {
  RTETextNode({
    required super.id,
    required this.text,
    this.format = const TextFormatRTE(),
  }) : super(type: 'text');

  /// Text content
  String text;

  /// Text format
  TextFormatRTE format;

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
