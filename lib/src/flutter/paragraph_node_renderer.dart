import 'package:flutter/widgets.dart';
import 'package:flutter_rte/flutter_rte.dart';

final class ParagraphNodeRendererFactory implements NodeRendererFactory<RTEParagraphNode> {
  @override
  String get nodeType => 'paragraph';

  @override
  NodeRendererWidget createNodeRenderer(RTEParagraphNode node) {
    return ParagraphNodeRenderer(node: node);
  }
}

class ParagraphNodeRenderer extends NodeRendererWidget<ParagraphNodeRenderer, RTEParagraphNode> {
  const ParagraphNodeRenderer({
    super.key,
    required this.node,
  });

  @override
  final RTEParagraphNode node;

  @override
  ParagraphRendererState createState() => ParagraphRendererState();
}

class ParagraphRendererState extends NodeRendererState<ParagraphNodeRenderer, RTEParagraphNode> {
  @override
  Widget build(BuildContext context) => Text(widget.node.toPlainText());
}