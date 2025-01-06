//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit
import Omnibar
import ExampleModel

protocol SearchHandler: AnyObject {
    func search(for searchTerm: String, offerSuggestion: Bool)
}

class OmnibarViewController: NSViewController {

    weak var searchHandler: SearchHandler?

    var omnibar: Omnibar! { return self.view as? Omnibar }
}

extension OmnibarViewController {
    
    func display(selectedWord: Word) {

        omnibar.display(content: .selection(text: selectedWord))
    }
}

extension OmnibarViewController: DisplaysSuggestion {

    func display(bestFit: String, forSearchTerm searchTerm: String) {

        guard let suggestion = Suggestion(bestFit: bestFit, forSearchTerm: searchTerm) else { return }

        omnibar.display(content: suggestion.omnibarContent)
    }
}

extension OmnibarViewController: OmnibarContentChangeDelegate {
    func omnibarDidCancelOperation(_ omnibar: Omnibar) {
        // nop
    }

    func omnibar(_ omnibar: Omnibar, didChangeContent contentChange: OmnibarContentChange, method: ChangeMethod) {
        guard method != .programmaticReplacement else { return }
        searchHandler?.search(
            for: contentChange.text,
            offerSuggestion: method == .appending)
    }

    func omnibar(_ omnibar: Omnibar, commit text: String) {
        let alert = NSAlert()
        alert.messageText = text
        alert.addButton(withTitle: "Continue")
        alert.runModal()
    }
}
