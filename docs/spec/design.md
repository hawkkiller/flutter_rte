# Design Overview

This section outlines the design of the project, including its architecture, components, and implementation details. If the **features document** answers the question _"What should the project do?"_, the **design document** addresses _"How should it be done?"_

**Note: This is a work in progress and may be subject to change.**

---

## Terminology

- **Node**: A mutable representation of content in the editor. It serves as the foundation upon which the actual content is rendered.
- **Document**: A collection of nodes that collectively represent the editor's content.
- **NodeRenderer**: A class responsible for rendering a node into a widget. Every node should have an associated renderer.
- **Selection**: A collection of nodes representing the current selection in the document. It tracks which part of the document the user is working with.
- **FlutterRTE** (Rich Text Editor, or RTE): The primary widget that represents the rich text editor.

---

## Architecture

### Nodes

Nodes form the core structure of the document by creating a tree-like hierarchy that represents the editor's content.
Each node in the tree has a specific type (e.g., text, paragraph) and a set of attributes (e.g., bold, italic).

#### Tree Structure Example:

For the following HTML content:

```html
<p>Hello, <b>wo<i>r</i>ld</b></p>
```

The tree structure would look like this:

```
DocumentNode (id: 1)
  └─ ParagraphNode (id: 2)
      └─ TextNode (id: 3) { text: "Hello, " }
      └─ TextNode (id: 4) { text: "wo", bold: true }
      └─ TextNode (id: 5) { text: "r", bold: true, italic: true }
      └─ TextNode (id: 6) { text: "ld", bold: true }
```

#### Characteristics of Nodes:
- **Mutability**: Nodes are mutable and can be updated in response to user interactions.
  For instance, when the user types a character, the corresponding text node is updated with the new character.
  When a style is applied (e.g., bold or italic), the node's attributes are updated to reflect this.
- **Uniqueness**: Each node has a unique identifier within the document, allowing the system to reference, find, and update specific nodes within the tree.
- **DocumentNode**: This node acts as the root of the tree and manages:
  - The **current selection**
  - **Notifications** about document changes (e.g., content updates, style changes)

---

### Selection

Selections allow users to highlight or focus on specific parts of the document. The selection is defined by two key points:
- **Anchor**: The starting point of the selection.
- **Focus**: The endpoint of the selection.

A selection can be:
- **Collapsed**: When the anchor and focus are the same point, indicating a single cursor position.
- **Non-collapsed**: When the anchor and focus differ, indicating a range of selected text.

#### Example: Simple Selection

Consider the text `Hello, world`, with the selection from "world" (`[` is the anchor and `]` is the focus):

```
Hello, [wo]rld
```

**Document Structure**:

```
DocumentNode (id: 1)
  └─ ParagraphNode (id: 2, index: 0)
      └─ TextNode (id: 3, index: 0) { text: "Hello, world" }
```

**Selection**:

```
anchor: { path: [0, 0], offset: 6 }
focus: { path: [0, 0], offset: 8 }
```

#### Example: Complex Selection Across Paragraphs

For the following HTML content, where the selection spans across two paragraphs:

```html
[<p>Hello, <b>wo<i>r</i>ld</b></p><br><p>Second paragraph</p>]
```

**Document Structure**:

```
DocumentNode (id: 1)
  └─ ParagraphNode (id: 2, index: 0)
      └─ TextNode (id: 3, index: 0) { text: "Hello, " }
      └─ TextNode (id: 4, index: 1) { text: "wo", bold: true }
      └─ TextNode (id: 5, index: 2) { text: "r", bold: true, italic: true }
      └─ TextNode (id: 6, index: 3) { text: "ld", bold: true }
  └─ LineBreakNode (id: 7, index: 1)
  └─ ParagraphNode (id: 8, index: 2)
      └─ TextNode (id: 9, index: 0) { text: "Second paragraph" }
```

**Selection**:

```
anchor: { path: [0, 0], offset: 0 }
focus: { path: [2, 0], offset: 16 }
```

---

### Node Renderer

Each node has a corresponding **NodeRenderer**, which transforms the node's data into a widget that can be displayed on the screen. 

#### Responsibilities of NodeRenderers:

- **Render content**: The renderer listens for changes in its associated node and updates the widget accordingly.
- **Handle selections**: Each renderer must handle selections, ensuring that the selected range is highlighted or visually indicated when it intersects with the node.
- **React to document changes**: NodeRenderers have access to the document and can react to changes like selection updates or style changes.
  
Renderers are typically implemented using **RenderObjectWidget** and **RenderObject** classes.

---

### Commands

Each user action in the editor (e.g., typing, styling text) is represented by a **Command**.
Commands encapsulate the logic necessary to perform or undo an action on the document.

#### Command Interface:

```dart
abstract interface class Command {
  void execute(Document document);
  void undo(Document document);
}
```

#### Example Flow:
1. **User Action**: The user types a character.
2. **Command Creation**: A command is generated by the DocumentRenderer to represent this action.
3. **Command Execution**: The command is executed on the document, updating the relevant node (e.g., appending the new character to a TextNode).
4. **Undo**: If needed, the command can also be undone, reverting the change to the document.
