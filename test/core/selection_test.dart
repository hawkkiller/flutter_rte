import 'package:flutter_rte/flutter_rte.dart';
import 'package:flutter_test/flutter_test.dart';

void main() => group(
      'NodeSelection',
      () {
        group(
          'NodePoint',
          () {
            test(
              'isInsideNode returns true if the point is inside the node',
              () {
                final point = NodePoint(path: [0, 1], offset: 3);
                final node = RTETextNode(id: '1', text: 'Hello, world!');
                expect(point.isInsideNode(node), isTrue);
              }
            );
          },
        );
      },
    );
