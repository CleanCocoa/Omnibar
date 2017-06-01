//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import ExampleModel

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
    lazy var filterQueue: DispatchQueue = DispatchQueue(label: "filter-queue", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
}

extension FilterService: SearchHandler {

    func displayAll() {

        search(for: "", offerSuggestion: false)
    }

    func search(for searchTerm: String, offerSuggestion: Bool) {

        filterQueue.async {
            self.wordsModel.filtered(searchTerm: searchTerm) { result in
                
                DispatchQueue.main.async {
                    if offerSuggestion,
                        let bestFit = result.bestMatch {
                        self.suggestionDisplay.display(bestFit: bestFit, forSearchTerm: searchTerm)
                    }

                    self.wordDisplay.display(words: result.words)
                }
            }
        }
    }
}
