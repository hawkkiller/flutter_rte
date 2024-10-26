import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rte/flutter_rte.dart';

/// Builder for a [TextSelectionGestureDetector] widget.
class SelectionGestureBuilder {
  SelectionGestureBuilder({
    required this.flutterRteRenderKey,
  });

  /// The [GlobalKey] of the [FlutterRte] widget.
  final GlobalKey flutterRteRenderKey;

  /// The [FlutterRteRender] of the [FlutterRte] widget.
  FlutterRteRender get flutterRteRender => flutterRteRenderKey.currentContext!.findRenderObject() as FlutterRteRender;

  TapDragDownDetails? _lastTapDownDetails;
  TapDragStartDetails? _lastDragStartDetails;

  void onTapDown(TapDragDownDetails details) {
    _lastTapDownDetails = details;
  }

  void onDragSelectionStart(TapDragStartDetails details) {
    _lastDragStartDetails = details;
  }

  void onDragSelectionUpdate(TapDragUpdateDetails details) {
    flutterRteRender.selectPositionAt(
      from: _lastDragStartDetails!.globalPosition,
      to: details.globalPosition,
      cause: SelectionChangedCause.drag,
    );
  }

  /// Builds a [TextSelectionGestureDetector] with the given [child].
  Widget build({required Widget child}) => TextSelectionGestureDetector(
        onTapDown: onTapDown,
        onDragSelectionStart: onDragSelectionStart,
        onDragSelectionUpdate: onDragSelectionUpdate,
        child: child,
      );
}
