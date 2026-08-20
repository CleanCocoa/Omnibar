//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

/// A single user interaction with an ``Omnibar``.
///
/// Events of all kinds share one stream because their relative order carries meaning: clearing the Omnibar with the Esc key emits a ``contentChange(_:method:)`` for the emptied text *before* the ``cancel`` that dismisses it.
public enum OmnibarEvent: Equatable, Sendable {

    /// The user-visible text changed, either from typing or from a call to `Omnibar.display(content:)`, as distinguished by `method`.
    case contentChange(OmnibarContentChange, method: ChangeMethod)

    /// The user confirmed the typed text, e.g. by hitting Return.
    case commit(text: String)

    /// The user dismissed the Omnibar, e.g. by hitting Esc.
    case cancel

    /// The user pressed a movement key to change the selection in the search results.
    case movement(MovementEvent)
}
