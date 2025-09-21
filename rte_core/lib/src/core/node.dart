import 'package:collection/collection.dart';

abstract class DocumentNode {
  const DocumentNode({
    required this.id,
    this.attributes = const {},
  });

  final String id;
  final Map<String, Object?> attributes;

  String get type;

  DocumentNode copyWith({
    String? id,
    Map<String, Object?>? attributes,
  });
}

/// A node that can contain other nodes.
abstract class BlockNode extends DocumentNode {
  const BlockNode({
    required super.id,
    this.children = const [],
    super.attributes,
  });

  final List<InlineNode> children;

  @override
  BlockNode copyWith({
    String? id,
    Map<String, Object?>? attributes,
    List<InlineNode>? children,
  });
}

abstract class InlineNode extends DocumentNode {
  const InlineNode({
    required super.id,
    super.attributes,
  });

  @override
  InlineNode copyWith({
    String? id,
    Map<String, Object?>? attributes,
  });
}

class ParagraphNode extends BlockNode {
  const ParagraphNode({
    required super.id,
    super.children,
    super.attributes,
  });

  @override
  String get type => 'paragraph';

  @override
  ParagraphNode copyWith({
    String? id,
    Map<String, Object?>? attributes,
    List<InlineNode>? children,
  }) {
    return ParagraphNode(
      id: id ?? this.id,
      attributes: attributes ?? this.attributes,
      children: children ?? this.children,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ParagraphNode &&
        other.id == id &&
        const DeepCollectionEquality().equals(other.attributes, attributes) &&
        const DeepCollectionEquality().equals(other.children, children);
  }

  @override
  int get hashCode =>
      id.hashCode ^
      const DeepCollectionEquality().hash(attributes) ^
      const DeepCollectionEquality().hash(children);
}

class TextNode extends InlineNode {
  const TextNode({
    required super.id,
    required this.text,
    super.attributes,
  });

  final String text;

  @override
  String get type => 'text';

  @override
  TextNode copyWith({
    String? id,
    Map<String, Object?>? attributes,
    String? text,
  }) {
    return TextNode(
      id: id ?? this.id,
      attributes: attributes ?? this.attributes,
      text: text ?? this.text,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TextNode &&
        other.id == id &&
        const DeepCollectionEquality().equals(other.attributes, attributes) &&
        other.text == text;
  }

  @override
  int get hashCode => id.hashCode ^ const DeepCollectionEquality().hash(attributes) ^ text.hashCode;
}
