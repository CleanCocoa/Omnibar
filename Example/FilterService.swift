//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import ExampleModel
import Foundation

protocol DisplaysWords {
    func display(words: [Word], selecting selectedWord: Word?)
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

    fileprivate var pendingRequest: Cancellable<FilterResults>?
}

extension FilterService: SearchHandler {

    func displayAll() {

        search(for: "", offerSuggestion: false)
    }

    func search(for searchTerm: String, offerSuggestion: Bool) {

        let newRequest = Cancellable<FilterResults> { [unowned self] result in
//            delayThread() // uncomment to reveal timing problems
            DispatchQueue.main.async {
                if offerSuggestion,
                    let bestFit = result.bestMatch {
                    self.suggestionDisplay.display(bestFit: bestFit, forSearchTerm: searchTerm)
                    self.wordDisplay.display(words: result.words, selecting: bestFit)
                } else {
                    self.wordDisplay.display(words: result.words, selecting: nil)
                }
            }
        }

        pendingRequest?.cancel()
        pendingRequest = newRequest

        filterQueue.async {
            self.wordsModel.filtered(searchTerm: searchTerm, result: newRequest.handler)
        }
    }
}
