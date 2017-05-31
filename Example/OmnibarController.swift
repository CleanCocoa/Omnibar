//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar

class OmnibarController: NSViewController, OmnibarDelegate {

    @IBOutlet weak var tableViewController: TableViewController!

    var omnibar: Omnibar! { return self.view as? Omnibar }

    func select(string: String) {

        omnibar.display(content: .selection(text: string))
    }

    func omnibarSelectNext(_ omnibar: Omnibar) {
        tableViewController.selectNext()
    }

    func omnibarSelectPrevious(_ omnibar: Omnibar) {
        tableViewController.selectPrevious()
    }
}
