//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

class WordsModel {

    private lazy var allWords: [String] = { try! Words.allWords() }()
    private var filteredWords: [String]?
    var currentWords: [String] {
        return filteredWords ?? allWords
    }

    var count: Int { return currentWords.count }

    subscript(index: Int) -> String {
        return currentWords[index]
    }

    func bestFit(startingWith searchTerm: String) -> String? {

        return currentWords.first
    }

    func filter(searchTerm: String) {

        guard !searchTerm.isEmpty else {
            filteredWords = nil
            return
        }

        let searchWords = searchTerm.lowercased().components(separatedBy: .whitespacesAndNewlines)

        let lazyFiltered = allWords.lazy
            .filter(containsAll(searchWords))
        filteredWords = Array(lazyFiltered)
    }
}

func containsAll(_ searchWords: [String]) -> (String) -> Bool {

    return { word in
        let word = word.lowercased()
        for searchWord in searchWords {
            if !word.contains(searchWord) { return false }
        }
        return true
    }
}
