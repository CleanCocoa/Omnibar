# Changelog

## 2.1.0

### Added

- `AsyncOmnibar` library: `OmnibarEvents` republishes the Omnibar's
  interactions as multicast `AsyncStream<OmnibarEvent>`s, and hands the
  delegate and action slots back on `finish()`. Additive; the `Omnibar`
  library is unchanged.

  RxOmnibar users blocked by 2.0.0 can move here instead of staying on
  1.0.0.

  This library needs Swift 6.2 (Xcode 26) for `isolated deinit`. The
  package's tools version stays at 6.1 so that depending on the `Omnibar`
  product alone keeps working on older toolchains, which never build this
  target.

## 2.0.0

Breaking release. The delegate protocol was split in two and renamed, so
adopters of 1.0.0 have to update their conformances.

### Added

- `Sendable` conformance on `OmnibarContent`, `OmnibarContentChange`,
  `ChangeMethod`, `MovementEvent`, and `Omnibar.Insets`.
- `OmnibarContentChange.string`, exposing the text including the suggestion
  appendix, alongside the existing `text`, which excludes it.

### Changed

- Requires macOS 15 and builds in the Swift 6 language mode.
- `OmnibarDelegate` is now `OmnibarContentChangeDelegate`, set through
  `omnibarContentChangeDelegate`, and is `@MainActor`. Its content callback
  is `omnibar(_:didChangeContent:method:)`.
- Selection changes moved off the delegate into the `moveFromOmnibar` action
  handler, which receives a `MovementEvent` with a `.up`/`.down`/`.top`/
  `.bottom` movement and an `isExpandingSelection` flag. This replaces
  `OmnibarSelectionDelegate` and its eight `omnibarSelect*`/`omnibarExpand*`
  methods.
- `display(content:)` now fires a `.programmaticReplacement` content change
  when displaying a selection.

### Removed

- The `DisplaysOmnibarContent` protocol, which was 1:1 the Omnibar itself.
- Public visibility of `String.prefixRange(of:options:)`,
  `String.removingSubrange(_:)`, `TextFieldTextPatch`,
  `doOmnibarCommand(commandSelector:)`, and
  `OmnibarTextFieldCell.drawingRect(forBounds:)`. None were part of the
  intended API.
- The Carthage Makefile, which referenced a Cartfile that no longer exists.

### Note for RxOmnibar users

[RxOmnibar](https://github.com/CleanCocoa/RxOmnibar) targets the 1.0.0
delegate API and does not compile against 2.0.0. Its `DelegateProxy` also
requires an `@objc` delegate protocol, which `OmnibarContentChangeDelegate`
no longer is. Stay on 1.0.0 until it is ported.

## 1.0.0

- Removed the bundled RxSwift extensions in favor of the separate
  [RxOmnibar](https://github.com/CleanCocoa/RxOmnibar) package.
