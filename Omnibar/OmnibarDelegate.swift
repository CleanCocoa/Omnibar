//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

@objc public protocol OmnibarSelectionDelegate: class {

    @objc optional func omnibarSelectNext(_ omnibar: Omnibar)
    @objc optional func omnibarSelectPrevious(_ omnibar: Omnibar)
}

public protocol OmnibarContentChangeDelegate: class {

    func omnibar(_ omnibar: Omnibar, contentChange: OmnibarContentChange)
}
