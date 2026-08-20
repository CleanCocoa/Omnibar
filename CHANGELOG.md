# Changelog

## 2.2.0

### Added

- `Omnibar.observe(_:)` and `Omnibar.events(bufferingPolicy:)`: any number
  of observers can watch one Omnibar, as closures or as `AsyncStream`s.
  `observe(_:)` returns an `Observation` whose `cancel()` is idempotent and
  independent of every other observer, so teardown order does not matter.

  `OmnibarEvent` moved into the `Omnibar` library. `AsyncOmnibar` re-exports
  it, so `import AsyncOmnibar` keeps compiling.

### Changed

- `OmnibarEvents` observes the Omnibar instead of taking over its
  `omnibarContentChangeDelegate` and `moveFromOmnibar` slots. **An
  application delegate now keeps receiving its callbacks while an
  `OmnibarEvents` is alive**, where 2.1.0 silenced it until `finish()`.
  Two `OmnibarEvents` on one Omnibar now both work; in 2.1.0 the second
  silently deafened the first.

- A handler that calls `display(content:)` re-entrantly no longer sees that
  echo dispatched before the event that caused it. The text field still
  mutates synchronously, so `stringValue` is up to date on return; only the
  notification is deferred until the outer dispatch finishes.

  **Delegate adopters upgrading from 2.1.0 should check for this.** The echo
  no longer arrives nested inside the callback that triggered it, so a
  delegate that suppresses its own echo by setting a flag around
  `display(content:)` will see the flag already cleared when the echo
  lands, and take the branch it wrote to avoid.

- The package no longer requires Swift 6.2. Ending the streams needs no
  `isolated deinit` any more, because the only state that teardown touches
  is `Sendable`.

### Deprecated

- Nothing. `omnibarContentChangeDelegate` and `moveFromOmnibar` keep working
  unchanged.

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
