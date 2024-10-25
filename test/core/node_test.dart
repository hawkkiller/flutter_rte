import 'package:flutter_rte/flutter_rte.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group(
      'RTENode',
      () {
        test(
          'constructs correct tree',
          () {
            final document = RTEDocumentNode(
              children: [
                RTEParagraphNode(
                  id: '2',
                  children: [
                    RTETextNode(id: '3', text: 'Hello, '),
                    RTETextNode(id: '4', text: 'world!'),
                  ],
                ),
              ],
            );
            expect(document.toPlainText(), 'Hello, world!');
          },
        );
        test(
          'serializes to json',
          () {
            final document = RTEDocumentNode(
              children: [
                RTEParagraphNode(
                  id: '2',
                  children: [
                    RTETextNode(id: '3', text: 'Hello, '),
                    RTETextNode(id: '4', text: 'world!'),
                  ],
                ),
              ],
            );

            expect(
              document.toJson(),
              {
                'type': 'document',
                'id': '1',
                'children': [
                  {
                    'type': 'paragraph',
                    'id': '2',
                    'children': [
                      {'type': 'text', 'id': '3', 'text': 'Hello, '},
                      {'type': 'text', 'id': '4', 'text': 'world!'},
                    ],
                  },
                ],
              },
            );
          },
        );
      },
    );
