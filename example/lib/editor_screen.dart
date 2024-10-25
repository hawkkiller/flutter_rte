import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_rte/flutter_rte.dart';

/// {@template editor_screen}
/// EditorScreen widget.
/// {@endtemplate}
class EditorScreen extends StatefulWidget {
  /// {@macro editor_screen}
  const EditorScreen({
    super.key, // ignore: unused_element
  });

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  /// The controller for the RichTextEditor widget.
  final controller = RichTextEditorController(
    RTEDocumentNode(children: [
      RTEParagraphNode(
        id: 'paragraph1',
        children: [
          ...List.generate(
            1000,
            (index) => RTETextNode(
              id: 'text$index',
              text: 'Text $index',
            ),
          ),
        ],
      ),
      RTEParagraphNode(id: 'linebreak'),
      RTEParagraphNode(
        id: 'paragraph2',
        children: [
          ...List.generate(
            1000,
            (index) => RTETextNode(
              id: 'text$index',
              text: 'Text $index',
              format: TextFormatRTE(
                bold: index % 2 == 0,
              ),
            ),
          ),
        ],
      ),
    ]),
  );

  @override
  Widget build(BuildContext context) {
    final rendererFactories = <NodeRendererFactory>{
      ParagraphNodeRendererFactory(
        textStyle: Theme.of(context).textTheme.bodyLarge,
      ),
    };

    return FlutterRte(
      controller: controller,
      rendererFactories: rendererFactories,
    );
  }
}
