import 'package:flutter/widgets.dart';
import 'package:flutter_rte/flutter_rte.dart';

/// {@template node_renderer_factory}
/// Factory for creating node renderers.
/// {@endtemplate}
abstract interface class NodeRendererFactory<NodeType extends RTENode> {
  /// The type of the node this widget renders.
  String get nodeType;

  /// Creates a new node renderer for the given node.
  NodeRendererWidget<NodeType> createNodeRenderer(
    NodeType node, {
    required NodeSelection? selection,
  });
}

/// {@template node_renderer_widget}
/// Widget that renders specific node.
/// {@endtemplate}
abstract class NodeRendererWidget<NodeType extends RTENode> extends LeafRenderObjectWidget {
  const NodeRendererWidget({
    required this.node,
    required this.selection,
    super.key,
  });

  /// The node this widget renders.
  final NodeType node;

  /// The selection of the node.
  final NodeSelection? selection;

  @override
  NodeRenderObject<NodeType> createRenderObject(BuildContext context);
}

/// {@template node_render_object}
/// Render object that renders specific node.
/// {@endtemplate}
abstract base class NodeRenderObject<NodeType extends RTENode> extends RenderBox {
  /// {@macro node_render_object}
  NodeRenderObject({
    required NodeType node,
    required NodeSelection? selection,
  })  : _node = node,
        _selection = selection;

  NodeType get node => _node;
  NodeType _node;
  set node(NodeType value) {
    if (_node == value) return;
    _node = value;
    markNeedsLayout();
  }

  NodeSelection? get selection => _selection;
  NodeSelection? _selection;
  set selection(NodeSelection? value) {
    if (_selection == value) return;
    _selection = value;
    markNeedsPaint();
  }
}
