import 'dart:collection';

import 'package:rte_core/src/document.dart';
import 'package:rte_core/src/document_operation.dart';
import 'package:rte_core/src/document_operation_reaction.dart';
import 'package:rte_core/src/document_range.dart';

/// Result of applying a [DocumentTransaction].
class TransactionResult {
  const TransactionResult({
    required this.document,
    required this.appliedOperations,
    this.selection,
  });

  final Document document;
  final List<DocumentOperation> appliedOperations;
  final DocumentRange? selection;
}

/// A batch of document operations applied atomically.
///
/// A transaction applies its operations in order to a base document.
/// Reactions are run after each operation and may enqueue additional operations.
class DocumentTransaction {
  DocumentTransaction({
    required this.base,
    List<DocumentOperation>? operations,
    this.reactions = const [],
    this.explicitSelection,
  }) : _operations = List.of(operations ?? const []);

  final Document base;
  final List<DocumentOperationReaction> reactions;
  final DocumentRange? explicitSelection;
  final List<DocumentOperation> _operations;

  List<DocumentOperation> get operations => UnmodifiableListView(_operations);

  /// Applies the transaction, returning the resulting document and selection.
  TransactionResult apply() {
    var current = base;
    final applied = <DocumentOperation>[];

    final queue = List<DocumentOperation>.of(_operations);
    while (queue.isNotEmpty) {
      final op = queue.removeAt(0);
      current = op.apply(current);
      applied.add(op);
      // Run reactions.
      for (final r in reactions) {
        final produced = r.react(current, op);
        if (produced.isNotEmpty) {
          queue.insertAll(0, produced); // ensure produced ops run next (depth-first)
        }
      }
    }

    return TransactionResult(
      document: current,
      appliedOperations: applied,
      selection: explicitSelection ?? current.selection,
    );
  }
}
