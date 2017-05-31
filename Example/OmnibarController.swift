//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar

class OmnibarController: NSViewController {

    var omnibar: Omnibar! { return self.view as? Omnibar }

    func select(string: String) {

        omnibar.display(content: .selection(text: string))
    }
}
