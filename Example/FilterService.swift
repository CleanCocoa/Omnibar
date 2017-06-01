//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

protocol DisplaysWords {
    func display(words: [String])
}

protocol DisplaysSuggestion {
    func display(bestFit: String, forSearchTerm searchTerm: String)
}

class FilterService {

    let suggestionDisplay: DisplaysSuggestion
    let wordDisplay: DisplaysWords

    init(
        suggestionDisplay: DisplaysSuggestion,
        wordDisplay: DisplaysWords) {

        self.suggestionDisplay = suggestionDisplay
        self.wordDisplay = wordDisplay
    }

    lazy var wordsModel: WordsModel = WordsModel()
}

extension FilterService: SearchHandler {

    func displayAll() {

        search(for: "", offerSuggestion: false)
    }

    func search(for searchTerm: String, offerSuggestion: Bool) {

        wordsModel.filtered(searchTerm: searchTerm) { result in

            if offerSuggestion,
                let bestFit = result.bestMatch {
                suggestionDisplay.display(bestFit: bestFit, forSearchTerm: searchTerm)
            }

            wordDisplay.display(words: result.words)
        }
    }
}
