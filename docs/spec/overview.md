# Overview

The Rich Text Editor should be a Flutter widget akin to the `TextField` or `EditableText` that supports additional
features. For example, it supports rich text formatting, such as bold, italic, underline, and strikethrough, as well as
inline images and links.

The RTE is designed to be highly customizable, with the ability to add custom formatting options, such as custom
text styles, custom inline widgets, and custom block widgets.

## Motivation

Current options for rich text editing in Flutter SDK are limited. While it is possible to use `EditableText` with custom
span styles, it doesn't seem to be a good fit for rich text editing. Some community packages try to implement this
functionality, but unfortunately, due to some reasons they have a bunch of issues which make them not suitable for
production use.

The goal of this project is to provide a well-designed and feature-rich rich text editor for Flutter.
Let's see how it goes!