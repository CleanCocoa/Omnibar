//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar

class OmnibarController: NSViewController {

    @IBOutlet weak var tableViewController: TableViewController!

    var omnibar: Omnibar! { return self.view as? Omnibar }

    func select(string: String) {
        omnibar.display(content: .selection(text: string))
    }
}

extension OmnibarController: OmnibarContentChangeDelegate {

    func omnibar(_ omnibar: Omnibar, contentChanges: OmnibarContentChange) {

        let searchTerm: String = {
            switch contentChanges {
            case .replacement(text: let text): return text
            case .continuation(text: let text, remainingAppendix: _): return text
            }
        }()

        tableViewController.filterResults(startingWith: searchTerm)
    }
}

extension OmnibarController: OmnibarSelectionDelegate {

    func omnibarSelectNext(_ omnibar: Omnibar) {
        tableViewController.selectNext()
    }

    func omnibarSelectPrevious(_ omnibar: Omnibar) {
        tableViewController.selectPrevious()
    }
}
