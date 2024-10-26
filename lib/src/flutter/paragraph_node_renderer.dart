import 'package:flutter/widgets.dart';
import 'package:flutter_rte/flutter_rte.dart';

final class ParagraphNodeRendererFactory implements NodeRendererFactory<RTEParagraphNode> {
  const ParagraphNodeRendererFactory({
    this.textStyle,
  });

  final TextStyle? textStyle;

  @override
  String get nodeType => 'paragraph';

  @override
  ParagraphNodeRendererWidget createNodeRenderer(
    RTEParagraphNode node, {
    required NodeSelection? selection,
  }) =>
      ParagraphNodeRendererWidget(
        node: node,
        selection: selection,
        textStyle: textStyle,
      );
}

class ParagraphNodeRendererWidget extends NodeRendererWidget<RTEParagraphNode> {
  const ParagraphNodeRendererWidget({
    super.key,
    required super.node,
    required super.selection,
    this.textStyle,
  });

  final TextStyle? textStyle;

  @override
  ParagraphNodeRenderObject createRenderObject(BuildContext context) => ParagraphNodeRenderObject(
        node: node,
        selection: selection,
        textStyle: textStyle,
      );

  @override
  void updateRenderObject(BuildContext context, ParagraphNodeRenderObject renderObject) {
    renderObject
      ..node = node
      ..selection = selection
      ..textStyle = textStyle;
  }
}

/// Render object that renders a paragraph node.
final class ParagraphNodeRenderObject extends NodeRenderObject<RTEParagraphNode> {
  ParagraphNodeRenderObject({
    required super.node,
    required super.selection,
    TextStyle? textStyle,
  }) : _textStyle = textStyle;

  TextStyle? get textStyle => _textStyle;
  TextStyle? _textStyle;
  set textStyle(TextStyle? value) {
    if (_textStyle == value) return;
    _textStyle = value;
    markNeedsLayout();
  }

  final _textPainter = TextPainter(textDirection: TextDirection.ltr);

  @override
  NodePoint? getNodePointForOffset(Offset offset) {
    final textPosition = _textPainter.getPositionForOffset(offset);

    return NodePoint(
      path: node.getPathToRoot(),
      offset: textPosition.offset,
    );
  }

  @override
  void performLayout() {
    final textNodes = node.children;

    _textPainter.text = TextSpan(
      children: [
        for (final textNode in textNodes)
          TextSpan(
            text: textNode.text,
            style: _textStyleFromTextFormatRTE(
              textStyle ?? const TextStyle(),
              textNode.format,
            ),
          ),
      ],
    );

    _textPainter.layout(
      minWidth: 0,
      maxWidth: constraints.maxWidth,
    );

    size = _textPainter.size;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint the text
    _textPainter.paint(context.canvas, offset);

    // If selection is not null, paint the selection
    if (selection case NodeSelection selection) {
      _paintSelection(
        context: context,
        selection: selection,
        offset: offset,
      );
    }
  }

  @override
  bool hitTestSelf(Offset position) => true;

  void _paintSelection({
    required PaintingContext context,
    required NodeSelection selection,
    required Offset offset,
  }) {
    final localTextSelection = selection.getLocalTextSelectionForNode(node);
    if (localTextSelection == null) return;

    // Get all the text boxes that overlap with the selection
    final selectionPoints = _textPainter.getBoxesForSelection(localTextSelection);

    // Create a paint object for the selection highlight
    final paint = Paint()
      ..color = const Color(0xFF2196F3).withOpacity(0.4) // Light blue selection color
      ..style = PaintingStyle.fill;

    for (final box in selectionPoints) {
      context.canvas.drawRect(
        box.toRect().shift(offset),
        paint,
      );
    }
  }
}

TextStyle _textStyleFromTextFormatRTE(TextStyle initial, TextFormatRTE textFormat) => initial.copyWith(
      fontWeight: textFormat.bold ? FontWeight.bold : null,
      fontStyle: textFormat.italic ? FontStyle.italic : null,
      decoration: textFormat.underline ? TextDecoration.underline : null,
    );
