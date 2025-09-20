import 'package:uuid/uuid.dart';

abstract class DocumentNode {
  DocumentNode({String? key, this.attributes = const {}}) : key = key ?? const Uuid().v4();

  final String key;
  final Map<String, Object?> attributes;

  DocumentNode copyWith({Map<String, Object?>? attributes});
}

abstract class ElementNode extends DocumentNode {
  ElementNode({required this.children, super.key});

  final List<DocumentNode> children;

  @override
  ElementNode copyWith({List<DocumentNode>? children, Map<String, Object?>? attributes});
}

class RootNode extends ElementNode {
  RootNode({required super.children, super.key});

  @override
  RootNode copyWith({List<DocumentNode>? children, Map<String, Object?>? attributes}) {
    return RootNode(children: children ?? this.children, key: key);
  }
}

class TextNode extends DocumentNode {
  TextNode({required this.text, required this.marks, super.key});

  final String text;
  final List<TextMark> marks;

  @override
  TextNode copyWith({String? text, List<TextMark>? marks, Map<String, Object?>? attributes}) {
    return TextNode(text: text ?? this.text, marks: marks ?? this.marks, key: key);
  }
}

enum TextMark { bold, italic, underline, strikethrough, code, link }
