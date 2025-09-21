import 'package:rte_core/src/core/document.dart';

/// A base class for any action that can be performed on a document.
///
/// Operations are self-contained, serializable, and represent a single,
/// atomic change to the document.
abstract class DocumentOperation {
  const DocumentOperation();

  /// Applies the operation to the given document and returns a new,
  /// modified document.
  Document apply(Document document);

  /// Returns an operation that reverses the effect of this operation when
  /// applied to the given document state.
  /// 
  /// [before] is the document state before this operation was applied.
  /// 
  /// Returns null if the operation is not invertible.
  DocumentOperation? invert(Document before) => null;
}
