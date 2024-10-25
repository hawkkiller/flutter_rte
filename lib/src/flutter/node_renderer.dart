import 'package:flutter/widgets.dart';
import 'package:flutter_rte/flutter_rte.dart';

/// {@template node_renderer_factory}
/// Factory for creating node renderers.
/// {@endtemplate}
abstract interface class NodeRendererFactory<T extends RTENode> {
  /// The type of the node this widget renders.
  String get nodeType;

  /// Creates a new node renderer for the given node.
  NodeRendererWidget createNodeRenderer(T node);
}

/// {@template node_renderer_widget}
/// Widget that renders specific node.
/// {@endtemplate}
abstract class NodeRendererWidget<T extends NodeRendererWidget<T, N>, N extends RTENode>
    extends StatefulWidget {
  const NodeRendererWidget({super.key});

  /// The node this widget renders.
  N get node;

  @override
  State<T> createState();
}

abstract class NodeRendererState<T extends NodeRendererWidget<T, N>, N extends RTENode> extends State<T> {
  /*
  Additional methods to think about
  */

  @override
  Widget build(BuildContext context);
}
