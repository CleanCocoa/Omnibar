//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit
import Omnibar
import ExampleModel

class OmnibarViewController: NSViewController {

    var omnibar: Omnibar! { return self.view as? Omnibar }
}

extension OmnibarViewController {

    func display(selectedWord: Word) {

        omnibar.display(content: .selection(text: selectedWord))
    }

    func confirm(text: String) {

        let alert = NSAlert()
        alert.messageText = text
        alert.addButton(withTitle: "Continue")
        alert.runModal()
    }
}

extension OmnibarViewController: DisplaysSuggestion {

    func display(bestFit: String, forSearchTerm searchTerm: String) {

        guard let suggestion = Suggestion(bestFit: bestFit, forSearchTerm: searchTerm) else { return }

        omnibar.display(content: suggestion.omnibarContent)
    }
}
