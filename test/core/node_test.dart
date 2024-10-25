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
                'id': 'root',
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
        test(
          'finds correct path to the root',
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

            final node = document.children.first.children.last;

            expect(node.id, equals('4'));
            expect(
              node.getPathToRoot(),
              equals([0, 1]),
            );
          },
        );
      },
    );
