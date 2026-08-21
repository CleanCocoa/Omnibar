# Omnibar

![Swift 6.2](https://img.shields.io/badge/Swift-6.2-blue.svg?style=flat)
![Version](https://img.shields.io/github/tag/CleanCocoa/Omnibar.svg?style=flat)
![Platform](https://img.shields.io/badge/platform-macOS%2015+-lightgrey.svg?style=flat)

A search field with support for auto-completion of typed strings.

> **Looking for RxSwift compatibility?** The reactive extensions (RxSwift) have moved to <https://github.com/CleanCocoa/RxOmnibar> after v0.21. That package targets the pre-2.0.0 delegate API and has not been updated for the renames in 2.0.0.

## Overview

Made to satisfy these needs:

1. Quickly filter search results;
2. Change result selection through use of the arrow keys from within the Omnibar;
3. Offer auto-completion of the search term inside the text field itself.

So if you type "aard", the Omnibar will suggest the term "aardvark" in the example app:

<div align="center">
    <img src="assets/suggestion.png" />
</div>


## Usage

### Displaying Values

Call `display(content: OmnibarContent)` to change the content of the Omnibar and affect the selection. You can also use the `stringValue` property to change the text and put the insertion point at the end like regular `NSTextField`s do.

```swift
public enum OmnibarContent {

    /// Empties the Omnibar.
    case empty

    /// Display `text` inside the Omnibar and select it all (like ⌘A) for
    /// quick overwriting.
    case selection(text: String)

    /// Display `text` inside the Omnibar and put the insertion point
    /// at the end.
    case prefix(text: String)

    /// Display `text`, followed by `appendix`, putting the insertion point
    /// before `appendix` and selecting it so it can be overwritten.
    case suggestion(text: String, appendix: String)
}
```

### Reacting to Events

An `Omnibar` has one observation surface, `OmnibarEvent`:

```swift
enum OmnibarEvent {
    case contentChange(OmnibarContentChange, method: ChangeMethod)
    case commit(text: String)
    case cancel
    case movement(MovementEvent)
}
```

`observe(_:)` registers a closure that runs synchronously, in the same turn as the event:

```swift
let observation = omnibar.observe { [weak self] event in
    switch event {
    case let .contentChange(change, method):
        guard method != .programmaticReplacement else { return }
        self?.search(for: change.text)
    case let .commit(text):
        self?.open(text)
    case let .movement(movement):
        self?.moveSelection(movement)
    case .cancel:
        break
    }
}
```

`observe(_:)` is not `@discardableResult`: dropping the returned `Observation` stops delivery, silently, so store it for as long as you want to keep listening. `cancel()` is idempotent and safe after the Omnibar is gone. Capture the Omnibar weakly inside the handler.

`events()` returns an `AsyncStream<OmnibarEvent>` instead, for `for await` consumers. It delivers on a later turn than the event that produced it:

```swift
for await event in omnibar.events() {
    handle(event)
}
```

The stream ends when the consuming task is cancelled or the Omnibar deallocates; every call to `events()` returns an independent stream that sees every event from that point on.

Use `observe(_:)` for arrow-key movement, where the selection change should land in the same turn as the text change that caused it, and `events()` for search, where a later turn is fine and `async`/`await` reads more naturally. The Example app does exactly this split.

`ChangeMethod` can be `.programmaticReplacement`, `.deletion`, `.insertion`, or `.appending` to convey what the user did so you can react to all cases differently. `display(content:)` produces `.programmaticReplacement`; filter it out with `method != .programmaticReplacement` to avoid reacting to your own echo.

`OmnibarContentChange` is either a `.replacement` of the old stuff, or a `.continuation` of the last suggestion, if there was any; `.continuation` is just like a self-suggested `OmnibarContent.suggestion` waiting for approval.

```swift
enum OmnibarContentChange {
    case replacement(text: String)
    case continuation(text: String, remainingAppendix: String)
}
```

### Ordering and Dispatch

All event kinds share one stream because their relative order carries meaning:

- Observers receive events in registration order.
- A recipient (observation or stream) registered during a dispatch does not receive the in-flight event; it receives the next one.
- A recipient cancelled during a dispatch still receives the in-flight event.
- An event caused by a handler — e.g. an observer calling `display(content:)` — is delivered after the event that caused it, to every recipient. One observer's echo cannot reach another observer before the event that produced it.
- Esc emits the `.contentChange` for the emptied text before `.cancel`, whether the field was already empty or the change arrives through the field editor deleting the text.

Displaying content stays synchronous — call `omnibar.display(content:)` from the main actor; `stringValue` is up to date on return. When `display(content:)` is called from inside a handler, the resulting event is delivered after the current one finishes, to every recipient. To discard results of a search the user has already typed past, cancel the previous task:

```swift
searchTask?.cancel()
searchTask = Task { ... }
```

# Attributions and Contributions

## English Open Word List (EOWL) v1.1.2

The sample app uses a list of 12000+ english words to display and filter.

> The “English Open Word List” (EOWL) was developed by Ken Loge, but is almost entirely derived from the “UK Advanced Cryptics Dictionary” (UKACD) Version 1.6, by J Ross Beresford.

- [English Open Word List](http://dreamsteep.com/projects/the-english-open-word-list.html)
- "UK Advanded Cryptics Dictionary" was formerly available at <http://cfaj.freeshell.org/wordfinder/UKACD17.shtml> but is now down

## License

### Omnibar

Copyright (c) 2017 Christian Tietze. Distributed under the MIT License.

### English Open Word List (EOWL)

Copyright © J Ross Beresford 1993-1999. All Rights Reserved. The following restriction is placed on the use of this publication: if the UK Advanced Cryptics Dictionary is used in a software package or redistributed in any form, the copyright notice must be prominently displayed and the text of this document must be included verbatim.

