import 'dart:math' as math;

import 'package:flutter/rendering.dart';
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

  TextSelection? getLocalTextSelectionForNode(RTENode node) {
    final pathToRoot = node.getPathToRoot();

    // Case 1: Either anchor or focus point is directly inside the node
    if (anchor.isInsidePath(pathToRoot) || focus.isInsidePath(pathToRoot)) {
      // Find the start and end points relative to the node
      final start = isBackward ? focus : anchor;
      final end = isBackward ? anchor : focus;

      // Calculate the relative offsets within the node
      int startOffset = start.isInsidePath(pathToRoot) ? start.offset : 0;
      int endOffset = end.isInsidePath(pathToRoot) ? end.offset : node.length;

      return TextSelection(
        baseOffset: startOffset,
        extentOffset: endOffset,
        isDirectional: true,
      );
    }

    // Case 2: Selection encompasses the node (starts before and ends after)
    final nodeStart = NodePoint(path: pathToRoot, offset: 0);
    final nodeEnd = NodePoint(path: pathToRoot, offset: node.length);

    if (isForward) {
      if (anchor.isBefore(nodeStart) && focus.isAfter(nodeEnd)) {
        return TextSelection(
          baseOffset: 0,
          extentOffset: node.length,
          isDirectional: true,
        );
      }
    } else {
      if (focus.isBefore(nodeStart) && anchor.isAfter(nodeEnd)) {
        return TextSelection(
          baseOffset: 0,
          extentOffset: node.length,
          isDirectional: true,
        );
      }
    }

    // No overlap
    return null;
  }

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is NodeSelection && other.anchor == anchor && other.focus == focus;
  }

  @override
  int get hashCode => Object.hash(anchor, focus);

  @override
  String toString() => 'NodeSelection(anchor: $anchor, focus: $focus)';
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

    return isInsidePath(pathToNode);
  }

  /// Returns true if this point is inside the given path.
  ///
  /// For example, if [otherPath] is [0, 1] and this point is [0, 1, 2], this would return true.
  /// If [otherPath] is [0, 1] and this point is [0, 2, 1], this would return false.
  @pragma('vm:prefer-inline')
  bool isInsidePath(List<int> otherPath) {
    if (path.length < otherPath.length) return false;

    for (var i = 0; i < otherPath.length; i++) {
      if (path[i] != otherPath[i]) return false;
    }

    return true;
  }

  /// Returns true if this point is before the given point.
  bool isBefore(NodePoint other) {
    return NodeSelection.comparePoints(this, other) < 0;
  }

  /// Returns true if this point is after the given point.
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

  @override
  String toString() => 'NodePoint(path: $path, offset: $offset)';
}
