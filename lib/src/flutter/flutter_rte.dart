import 'package:collection/collection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/src/gestures/hit_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rte/flutter_rte.dart';
import 'package:flutter_rte/src/flutter/selection_gesture_builder.dart';

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
  State<FlutterRte> createState() => FlutterRteState();
}

class FlutterRteState extends State<FlutterRte> {
  /// The renderer factories map.
  Map<String, NodeRendererFactory> get _rendererFactoriesMap => {
        for (final factory in widget.rendererFactories) factory.nodeType: factory,
      };

  final _globalKey = GlobalKey<FlutterRteState>();

  late final _selectionGestureBuilder = SelectionGestureBuilder(
    flutterRteRenderKey: _globalKey,
  );

  NodeSelection? _selection = const NodeSelection(
    NodePoint(path: [1], offset: 0),
    NodePoint(path: [1], offset: 10),
  );

  void _handleSelectionChanged(NodeSelection? selection) {
    setState(() {
      _selection = selection;
    });
  }

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
        valueListenable: widget.controller,
        builder: (context, value, _) => Scrollable(
          viewportBuilder: (BuildContext context, ViewportOffset position) => _selectionGestureBuilder.build(
            child: _FlutterRteWidget(
              key: _globalKey,
              offset: position,
              onSelectionChanged: _handleSelectionChanged,
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
        ),
      );
}

class _FlutterRteWidget extends MultiChildRenderObjectWidget {
  const _FlutterRteWidget({
    required this.offset,
    required this.onSelectionChanged,
    required super.children,
    super.key,
  });

  final ViewportOffset offset;
  final ValueChanged<NodeSelection?> onSelectionChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      FlutterRteRender(offset: offset, onSelectionChanged: onSelectionChanged);

  @override
  void updateRenderObject(BuildContext context, FlutterRteRender renderObject) {
    renderObject
      ..offset = offset
      ..onSelectionChanged = onSelectionChanged;
  }
}

class _FlutterRteParentData extends ContainerBoxParentData<RenderBox> {}

class FlutterRteRender extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FlutterRteParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _FlutterRteParentData> {
  FlutterRteRender({
    required ViewportOffset offset,
    required ValueChanged<NodeSelection?> onSelectionChanged,
  })  : _offset = offset,
        _onSelectionChanged = onSelectionChanged;

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

  ValueChanged<NodeSelection?> get onSelectionChanged => _onSelectionChanged;
  ValueChanged<NodeSelection?> _onSelectionChanged;
  set onSelectionChanged(ValueChanged<NodeSelection?> value) {
    if (_onSelectionChanged == value) {
      return;
    }
    _onSelectionChanged = value;
  }

  /// The offset at which the contents should be painted.
  Offset get _paintOffset => Offset(0.0, -offset.pixels);

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _offset.addListener(markNeedsPaint);

    _tap = TapGestureRecognizer(debugOwner: this)
      ..onTapDown = _handleTapDown
      ..onTap = _handleTap;
    _longPress = LongPressGestureRecognizer(debugOwner: this)..onLongPress = _handleLongPress;
  }

  @override
  void detach() {
    _offset.removeListener(markNeedsPaint);

    _tap.dispose();
    _longPress.dispose();

    super.detach();
  }

  void _handleTapDown(TapDownDetails details) {
    _lastTapDownPosition = details.globalPosition;
  }

  void _handleTap() {
    selectPosition(cause: SelectionChangedCause.tap);
  }

  void _handleLongPress() {
    selectPosition(cause: SelectionChangedCause.longPress);
  }

  /// Move selection to the location of the last tap down.
  ///
  /// {@template flutter.rendering.RenderEditable.selectPosition}
  /// This method is mainly used to translate user inputs in global positions
  /// into a [TextSelection]. When used in conjunction with a [EditableText],
  /// the selection change is fed back into [TextEditingController.selection].
  ///
  /// If you have a [TextEditingController], it's generally easier to
  /// programmatically manipulate its `value` or `selection` directly.
  /// {@endtemplate}
  void selectPosition({required SelectionChangedCause cause}) {
    selectPositionAt(from: _lastTapDownPosition!, cause: cause);
  }

  /// Select text between the global positions [from] and [to].
  ///
  /// [from] corresponds to the [TextSelection.baseOffset], and [to] corresponds
  /// to the [TextSelection.extentOffset].
  void selectPositionAt({required Offset from, Offset? to, required SelectionChangedCause cause}) {
    // Need to convert the global position to a local position.
    // Then find render object on that position and calculate [NodeSelection].

    final nodeRenderObjectFrom = findNodeRenderObjectAt(from);

    if (nodeRenderObjectFrom == null) {
      return;
    }

    final nodePointFrom = nodeRenderObjectFrom.getNodePointForOffset(
      from - _paintOffset - (nodeRenderObjectFrom.parentData as _FlutterRteParentData).offset,
    );

    if (nodePointFrom == null) {
      return;
    }

    final nodeRenderObjectTo = to != null ? findNodeRenderObjectAt(to) : null;

    if (nodeRenderObjectTo != null) {
      final nodePointTo = nodeRenderObjectTo.getNodePointForOffset(
        to! - _paintOffset - (nodeRenderObjectTo.parentData as _FlutterRteParentData).offset,
      );

      if (nodePointTo != null) {
        onSelectionChanged(NodeSelection(nodePointFrom, nodePointTo));
      }
    } else {
      onSelectionChanged(NodeSelection.collapsed(nodePointFrom));
    }
  }

  NodeRenderObject? findNodeRenderObjectAt(Offset position) {
    final hitTestResult = BoxHitTestResult();

    hitTest(hitTestResult, position: position);

    // find first render object with type NodeRenderObject
    return hitTestResult.path.firstWhereOrNull((entry) => entry.target is NodeRenderObject)?.target
        as NodeRenderObject?;
  }

  Offset? _lastTapDownPosition;
  late TapGestureRecognizer _tap;
  late LongPressGestureRecognizer _longPress;

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      defaultHitTestChildren(result, position: position - _paintOffset);

  @override
  void handleEvent(
    PointerEvent event,
    covariant HitTestEntry<HitTestTarget> entry,
  ) {
    assert(debugHandleEvent(event, entry));
    if (event is PointerDownEvent) {
      assert(!debugNeedsLayout);

      // Propagates the pointer event to selection handlers.
      _tap.addPointer(event);
      _longPress.addPointer(event);
    }
  }

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
