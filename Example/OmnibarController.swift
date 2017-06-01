//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar

class OmnibarController: NSViewController {

    @IBOutlet weak var tableViewController: TableViewController!

    var omnibar: Omnibar! { return self.view as? Omnibar }

    func select(string: String) {
        omnibar.display(content: .selection(text: string))
    }

    func display(bestFit: String, forSearchTerm searchTerm: String) {

        guard let matchRange = bestFit.lowercased().range(of: searchTerm.lowercased()),
            matchRange.lowerBound == bestFit.startIndex
            else { preconditionFailure("display(bestFit:forSearchTerm:) must be called with `searchTerm` starting `bestFit`") }

        let appendix = bestFit.removingSubrange(matchRange)

        omnibar.display(content: .suggestion(text: searchTerm, appendix: appendix))
    }
}

extension OmnibarController: OmnibarContentChangeDelegate {

    func omnibar(_ omnibar: Omnibar, contentChange: OmnibarContentChange) {

        let searchTerm: String = {
            switch contentChange {
            case .replacement(text: let text): return text
            case .continuation(text: let text, remainingAppendix: _): return text
            }
        }()

        tableViewController.filterResults(searchTerm: searchTerm)
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
