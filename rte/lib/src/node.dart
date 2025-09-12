import 'package:uuid/uuid.dart';

abstract class DocumentNode {
  DocumentNode({String? key}) : key = key ?? const Uuid().v4();

  final String key;
}

abstract class ElementNode extends DocumentNode {
  ElementNode({required this.children, super.key});

  final List<DocumentNode> children;

  ElementNode copyWith({List<DocumentNode>? children});
}

class RootNode extends ElementNode {
  RootNode({required super.children, super.key});

  @override
  RootNode copyWith({List<DocumentNode>? children}) {
    return RootNode(children: children ?? this.children, key: key);
  }
}

class TextNode extends DocumentNode {
  TextNode({required this.text, required this.marks, super.key});

  final String text;
  final List<TextMark> marks;

  TextNode copyWith({String? text, List<TextMark>? marks}) {
    return TextNode(text: text ?? this.text, marks: marks ?? this.marks, key: key);
  }
}

enum TextMark { bold, italic, underline, strikethrough, code, link }
