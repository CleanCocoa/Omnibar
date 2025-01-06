//  Copyright © 2025 Christian Tietze. All rights reserved. Distributed under the MIT License.

@MainActor
public protocol OmnibarContentChangeDelegate: AnyObject {

    /// Callback for live changes to the user-visible text, both while typing and from programmatic changes to the displayed content (as distingushed by `method`).
    func omnibar(
        _ omnibar: Omnibar,
        didChangeContent contentChange: OmnibarContentChange,
        method: ChangeMethod
    )

    /// Indicates the user confirms the currently typed text.
    func omnibar(
        _ omnibar: Omnibar,
        commit text: String
    )

    /// Indicates the user did press ESC or ⌘. inside the Omnibar _after_ a content change is dispatched.
    func omnibarDidCancelOperation(_ omnibar: Omnibar)
}
