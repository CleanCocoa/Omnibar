//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

@objc public protocol OmnibarDelegate: class {

    func omnibarSelectNext(_ omnibar: Omnibar)
    func omnibarSelectPrevious(_ omnibar: Omnibar)

    func omnibar(_ omnibar: Omnibar, typed string: String)
}
