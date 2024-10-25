import 'dart:math' as math;

import 'package:flutter_rte/flutter_rte.dart';
import 'package:flutter_rte/src/utils/equality.dart';

/// {@template node_selection}
/// [NodeSelection] represents a selection in the document.
/// {@endtemplate}
class NodeSelection {
  /// Creates a selection that starts and ends at the given points.
  const NodeSelection(this.anchor, this.focus);

  /// Creates a selection that is collapsed at the given point.
  const NodeSelection.collapsed(NodePoint point)
      : anchor = point,
        focus = point;

  /// The place where selection has started.
  final NodePoint anchor;

  /// The place where selection has ended.
  final NodePoint focus;

  /// Returns true if the selection starts and ends at the same point.
  bool get isCollapsed => anchor == focus;

  /// Returns true if the achor comes after the focus.
  bool get isBackward => comparePoints(anchor, focus) > 0;

  /// Returns true if the achor comes before the focus.
  bool get isForward => comparePoints(anchor, focus) < 0;

  /// Compares two [NodePoint]s.
  static int comparePoints(NodePoint a, NodePoint b) {
    // Compare paths first
    final minLength = math.min(a.path.length, b.path.length);

    // Compare each element in the path until we find a difference
    for (var i = 0; i < minLength; i++) {
      if (a.path[i] != b.path[i]) {
        return a.path[i].compareTo(b.path[i]);
      }
    }

    // If one path is longer than the other, the longer one comes after
    if (a.path.length != b.path.length) {
      return a.path.length.compareTo(b.path.length);
    }

    // If paths are identical, compare offsets
    return a.offset.compareTo(b.offset);
  }
}

/// {@template node_point}
/// [NodePoint] represents a single point in the document.
/// {@endtemplate}
class NodePoint {
  /// {@macro node_point}
  const NodePoint({required this.path, required this.offset});

  /// The path to the node.
  ///
  /// For example, [0, 1, 1] would refer to the second child of the second child of the first child.
  final List<int> path;

  /// The offset within the node.
  ///
  /// For example, if the node is a text node, this would be the character offset.
  final int offset;

  /// Returns true if this point is inside the given node.
  bool isInsideNode(RTENode node) {
    final pathToNode = node.getPathToRoot();

    // If the path is longer than the node's path, it can't be inside the node
    if (pathToNode.length < path.length) {
      return false;
    }

    // Check if the first n elements of the path are the same
    for (var i = 0; i < path.length; i++) {
      if (path[i] != pathToNode[i]) {
        return false;
      }
    }

    return true;
  }

  bool isBefore(NodePoint other) {
    return NodeSelection.comparePoints(this, other) < 0;
  }

  bool isAfter(NodePoint other) {
    return NodeSelection.comparePoints(this, other) > 0;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NodePoint && listEquals(other.path, path) && other.offset == offset;
  }

  @override
  int get hashCode => Object.hashAll(path) ^ offset;
}
