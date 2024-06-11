# Design

This section describes the design of the project, including the architecture, components, and implementation details.
If the features document answers the question "What should the project do?", the design document answers the question
"How should the project do it?"

**It is a work in progress and is subject to change**.

Terms used in the architecture:

- **Node**—a mutable representation of content in the editor. Based on it, the actual content is rendered.
- **Document**—a collection of nodes that represent the content of the editor.
- **NodeRenderer**—a class that renders a node into a widget. Each node should have a corresponding renderer.
- **FlutterRte** (or RTE)—the main widget that represents the rich text editor.
- **NodePath**—a path to a node in the document. It is used to identify an accurate position in the document. It
  contains a list of indices that represent the path to the node.
- **Selection**—a selection of nodes in the document. It is used to represent the current selection in the editor. It
  contains a list of node paths that represent the selected nodes plus the start and end offsets in the first and last
  nodes.

## Nodes

The `Node` class is the base class for all nodes in the editor.
It contains the needed information to render the node into a widget.
Node is a mutable representation of content in the editor, just like a DOM node in the web or element in the Flutter
element tree.

Nodes form a tree structure, where each node can have zero or more children.
The root node is the document node, which contains all other nodes in the editor. It also manages the selection and
cursor position in the editor, layout, and rendering.

The `Node` class should have a unique identifier, a type and a list of children nodes, potentially links to the parent
and sibling nodes.
Extending the `Node` class, we can create specific types of nodes, such as text nodes, block nodes,
or inline nodes. Each type of node can have its own set of attributes, behaviors, and rendering logic.

### DocumentNode

This should be the root node, acting as a container for all other nodes.
Its primary function would be to manage the document layout and to handle high-level operations such as serialization
and deserialization of the entire document content.

### ElementNode

The `ElementNode` class represents a block-level element in the editor.
It contains a list of child nodes that represent the content of the element.
Element nodes are non-leaf nodes in the tree structure, meaning they can have children.

**TODO**: Should there be a separate class for element nodes? Or should we use the base `Node` class for all nodes?

### TextNode

The `TextNode` class represents a piece of text in the editor.
It contains the actual text content and any formatting information associated with the text, such as bold, italic,
underline, or strikethrough styles. Text nodes are leaf nodes and do not have children.

### Other Node Types

Other node types can be added as needed. For example, other block-level elements like paragraphs, headings, lists, or
tables can be represented by specific node types.
Specific node types can also represent inline elements like links, mentions, hashtags, or custom inline widgets.

## Rendering and Layout

Every node in the document must have a corresponding renderer that knows how to render the node into a widget.
The renderers should be responsible for creating the appropriate widgets based on the node type and its attributes.

As the text is entered and edited in the editor, we can't use simple `Text` widgets to render the content because it is
not editable.
Instead, we need to develop custom widgets that can handle text input and editing, such as `EditableText`.

### Document Renderer

The `DocumentRenderer` class is responsible for rendering the entire document into a widget.
It should traverse the document tree, call the appropriate renderers for each node, and assemble the resulting widgets
into a single widget tree.
This process should be efficient so that unchanged parts of the document are not re-layouted.

`DocumentRenderer` should also handle selection updates, meaning it should understand the `Pointer` events and update
the selection based on the user's interactions.
