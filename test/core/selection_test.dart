import 'package:flutter_rte/flutter_rte.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group(
      'NodeSelection',
      () {
        group(
          'NodePoint',
          () {
            test('isInsideNode returns true if the point is inside the node', () {
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

              final node = document.children.first;
              const point = NodePoint(
                path: [0],
                offset: 2,
              );

              expect(point.isInsideNode(node), isTrue);
            });

            test(
              'isBefore and isAfter returns correctly',
              () {
                const point1 = NodePoint(path: [0], offset: 2);
                const point2 = NodePoint(path: [0], offset: 3);

                expect(point1.isBefore(point2), isTrue);
                expect(point1.isAfter(point2), isFalse);
                
                expect(point2.isBefore(point1), isFalse);
                expect(point2.isAfter(point1), isTrue);
              },
            );
          },
        );
      },
    );
