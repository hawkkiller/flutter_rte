## Node Types

The document is made up of different types of nodes. Node is an object that carries some data that is used to render the document.

There are three foundational node types:
- DocumentNode: a superclass that defines common properties for all nodes.
- BlockNode: a node that represents a block-level element (e.g., paragraph, heading, list item).
- InlineNode: a node that represents an inline-level element (e.g., text, link).

Additionally, there are specialized node types that extend these foundational types:

- ParagraphNode: a block node that represents a paragraph of text.
- TextNode: an inline node that represents a piece of text with optional formatting marks.
- HeadingNode: a block node that represents a heading with a specified level.
- LinkNode: an inline node that represents a hyperlink with a URL and optional title.