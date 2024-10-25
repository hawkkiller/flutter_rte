import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rte/flutter_rte.dart';

/// {@template rich_text_editor_controller}
/// Controller for the RichTextEditor widget.
/// {@endtemplate}
class RichTextEditorController extends ValueNotifier<RTEDocumentNode> {
  /// {@macro rich_text_editor_controller}
  RichTextEditorController(super.document);

  RichTextEditorController.empty() : super(RTEDocumentNode.empty());

  /// Nodes of the document
  List<RTENode> get nodes => value.children;
}

/// {@template flutter_rte}
/// FlutterRte widget.
/// {@endtemplate}
class FlutterRte extends StatefulWidget {
  /// {@macro flutter_rte}
  const FlutterRte({
    required this.controller,
    required this.rendererFactories,
    super.key,
  });

  /// The controller for the RichTextEditor widget.
  final RichTextEditorController controller;

  /// The node renderer factories.
  final Set<NodeRendererFactory> rendererFactories;

  @override
  State<FlutterRte> createState() => _FlutterRteState();
}

class _FlutterRteState extends State<FlutterRte> {
  /// The renderer factories map.
  Map<String, NodeRendererFactory> get _rendererFactoriesMap => {
        for (final factory in widget.rendererFactories) factory.nodeType: factory,
      };

  NodeSelection? _selection = const NodeSelection(
    NodePoint(path: [1, 1], offset: 0),
    NodePoint(path: [1, 18], offset: 3),
  );

  @override
  Widget build(BuildContext context) {
    CustomScrollView;
    EditableText;
    RenderViewport;

    return ValueListenableBuilder(
      valueListenable: widget.controller,
      builder: (context, value, _) => Scrollable(
        viewportBuilder: (BuildContext context, ViewportOffset position) => _FlutterRteWidget(
          offset: position,
          children: [
            for (final node in value.children)
              if (_rendererFactoriesMap.containsKey(node.type))
                _rendererFactoriesMap[node.type]!.createNodeRenderer(
                  node,
                  selection: _selection,
                )
              else
                Placeholder(child: Text('Unsupported node type: ${node.type}'))
          ],
        ),
      ),
    );
  }
}

class _FlutterRteWidget extends MultiChildRenderObjectWidget {
  const _FlutterRteWidget({
    required this.offset,
    required super.children,
  });

  final ViewportOffset offset;

  @override
  RenderObject createRenderObject(BuildContext context) => _FlutterRteRender(
        offset: offset,
      );

  @override
  void updateRenderObject(BuildContext context, _FlutterRteRender renderObject) {
    renderObject.offset = offset;
  }
}

class _FlutterRteParentData extends ContainerBoxParentData<RenderBox> {}

class _FlutterRteRender extends RenderBox with ContainerRenderObjectMixin<RenderBox, _FlutterRteParentData> {
  _FlutterRteRender({
    required ViewportOffset offset,
  }) : _offset = offset {
    _offset.addListener(markNeedsPaint);
  }

  /// The offset at which the text should be painted.
  ///
  /// If the text content is larger than the editable line itself, the editable
  /// line clips the text. This property controls which part of the text is
  /// visible by shifting the text by the given offset before clipping.
  ViewportOffset get offset => _offset;
  ViewportOffset _offset;
  set offset(ViewportOffset value) {
    if (_offset == value) {
      return;
    }
    if (attached) {
      _offset.removeListener(markNeedsPaint);
    }
    _offset = value;
    if (attached) {
      _offset.addListener(markNeedsPaint);
    }
    markNeedsLayout();
  }

  /// The offset at which the contents should be painted.
  Offset get _paintOffset => Offset(0.0, -offset.pixels);

  @override
  void setupParentData(covariant RenderObject child) {
    if (child.parentData is! _FlutterRteParentData) {
      child.parentData = _FlutterRteParentData();
    }
  }

  @override
  void performLayout() {
    size = constraints.biggest;

    double height = 0;

    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as _FlutterRteParentData;
      child.layout(
        constraints.copyWith(
          minHeight: 0,
          maxHeight: double.infinity,
        ),
        parentUsesSize: true,
      );
      childParentData.offset = Offset(0, height);
      height += child.size.height;

      child = childParentData.nextSibling;
    }

    offset.applyViewportDimension(constraints.maxHeight);
    offset.applyContentDimensions(0, height - constraints.maxHeight);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = firstChild;
    while (child != null) {
      final childParentData = child.parentData as _FlutterRteParentData;
      context.paintChild(child, childParentData.offset + offset + _paintOffset);

      child = childParentData.nextSibling;
    }
  }
}
