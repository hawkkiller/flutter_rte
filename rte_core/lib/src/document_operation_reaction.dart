import 'package:rte_core/src/document.dart';
import 'package:rte_core/src/document_operation.dart';

/// A reaction to a [DocumentOperation] that can produce additional operations
/// to be applied in response.
abstract class DocumentOperationReaction {
  const DocumentOperationReaction();

  /// Reacts to the given operation and returns a list of operations to be
  /// applied.
  List<DocumentOperation> react(Document document, DocumentOperation operation);
}
