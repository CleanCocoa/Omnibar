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

    /// Cancelled whenever a newer search starts, so results the user has typed past are never displayed.
    private var pendingSearch: Task<Void, Never>?
}

extension FilterService {

    func displayAll() {

        search(for: "", offerSuggestion: false)
    }

    func search(for searchTerm: String, offerSuggestion: Bool) {

        pendingSearch?.cancel()
        pendingSearch = Task {
            let result = await filtered(searchTerm)

            guard !Task.isCancelled else { return }

            if offerSuggestion,
                let bestFit = result.bestMatch {
                suggestionDisplay.display(bestFit: bestFit, forSearchTerm: searchTerm)
                wordDisplay.display(words: result.words, selecting: bestFit)
            } else {
                wordDisplay.display(words: result.words, selecting: nil)
            }
        }
    }
}

/// Loaded on first use, i.e. from ``filtered(_:)`` and thus off the main actor.
private nonisolated let wordsModel = WordsModel()

/// Runs off the main actor: filtering 12000+ words on every keystroke would stutter typing in the Omnibar.
@concurrent
private func filtered(_ searchTerm: String) async -> FilterResults {

//    try? await Task.sleep(for: .milliseconds(Int.random(in: 0...3000))) // uncomment to reveal timing problems
    return wordsModel.filtered(searchTerm: searchTerm)
}
