//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar
import ExampleModel

protocol SearchHandler: class {
    func search(for searchTerm: String, offerSuggestion: Bool)
}

protocol SelectsResult: class {
    func selectNext()
    func selectPrevious()
}

class OmnibarController: NSViewController {

    weak var searchHandler: SearchHandler?
    weak var selectionHandler: SelectsResult?

    var omnibar: Omnibar! { return self.view as? Omnibar }
}

extension OmnibarController: SelectsWord {
    
    func select(word: Word) {
        
        omnibar.display(content: .selection(text: word))
    }
}

extension OmnibarController: DisplaysSuggestion {

    func display(bestFit: String, forSearchTerm searchTerm: String) {

        guard let matchRange = bestFit.lowercased().range(of: searchTerm.lowercased()),
            matchRange.lowerBound == bestFit.startIndex
            else { preconditionFailure("display(bestFit:forSearchTerm:) must be called with `searchTerm` starting `bestFit`") }

        let appendix = bestFit.removingSubrange(matchRange)

        omnibar.display(content: .suggestion(text: searchTerm, appendix: appendix))
    }
}

extension OmnibarController: OmnibarDelegate {

    func omnibar(_ omnibar: Omnibar, contentChange: OmnibarContentChange, method: ChangeMethod) {

        searchHandler?.search(
            for: contentChange.text,
            offerSuggestion: method == .insertion)
    }

    func omnibarSelectNext(_ omnibar: Omnibar) {
        selectionHandler?.selectNext()
    }

    func omnibarSelectPrevious(_ omnibar: Omnibar) {
        selectionHandler?.selectPrevious()
    }
}
