//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

@objc public protocol OmnibarSelectionDelegate: class {

    /// Called when the up arrow key is pressed from inside the Omnibar while
    /// the Command or Alt modifier key is held.
    @objc optional func omnibarSelectFirst(_ omnibar: Omnibar)

    /// Called when the up arrow key is pressed from inside the Omnibar.
    @objc optional func omnibarSelectPrevious(_ omnibar: Omnibar)

    /// Called when the down arrow key is pressed from inside the Omnibar.
    @objc optional func omnibarSelectNext(_ omnibar: Omnibar)

    /// Called when the down arrow key is pressed from inside the Omnibar while
    /// the Command or Alt modifier key is held.
    @objc optional func omnibarSelectLast(_ omnibar: Omnibar)
}

public protocol OmnibarContentChangeDelegate: class {

    /// Callback for live changes to the user-visible text while typing.
    func omnibar(_ omnibar: Omnibar, contentChange: OmnibarContentChange, method: ChangeMethod)

    /// Indicates the user confirms the currently typed text.
    func omnibar(_ omnibar: Omnibar, commit text: String)
}

public typealias OmnibarDelegate = OmnibarSelectionDelegate & OmnibarContentChangeDelegate
