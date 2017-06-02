//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import ExampleModel

protocol DisplaysWords {
    func display(words: [String])
}

class FilterService {

    let wordDisplay: DisplaysWords

    init(wordDisplay: DisplaysWords) {

        self.wordDisplay = wordDisplay
    }

    lazy var wordsModel: WordsModel = WordsModel()
    lazy var filterQueue: DispatchQueue = DispatchQueue(label: "filter-queue", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
}

extension FilterService: SearchHandler {

    func displayAll() {
        search(for: "")
    }

    func search(
        for searchTerm: String,
        suggestionCallback: ((_ bestFit: String, _ searchTerm: String) -> Void)? = nil
        ) {

        filterQueue.async {
            self.wordsModel.filtered(searchTerm: searchTerm) { result in
                
                DispatchQueue.main.async {
                    if let suggestionCallback = suggestionCallback,
                        let bestFit = result.bestMatch {
                        suggestionCallback(bestFit, searchTerm)
                    }

                    self.wordDisplay.display(words: result.words)
                }
            }
        }
    }
}
