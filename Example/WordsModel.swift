//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

struct FilterResults {

    let words: [String]
    let bestMatch: String?

    init(words: [String], bestMatch: String? = nil) {

        self.words = words
        self.bestMatch = bestMatch
    }
}

struct WordsModel {

    private let allWords: [String] = { try! Words.allWords() }()

    func filtered(searchTerm: String, result: (FilterResults) -> Void) {

        guard !searchTerm.isEmpty else {
            result(FilterResults(words: allWords))
            return
        }

        let filteredWords = filter(haystack: allWords, searchTerm: searchTerm)
        let bestMatch = bestFit(haystack: filteredWords, needleStartingWith: searchTerm)

        result(FilterResults(
            words: filteredWords,
            bestMatch: bestMatch))
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

func bestFit(haystack: [String], needleStartingWith searchTerm: String) -> String? {

    guard !searchTerm.isEmpty else { return nil }

    return haystack.first { $0.lowercased().hasPrefix(searchTerm.lowercased()) }
}

func filter(haystack: [String], searchTerm: String) -> [String] {

    let searchWords = searchTerm.lowercased().components(separatedBy: .whitespacesAndNewlines)
    let filtered = haystack.filter(containsAll(searchWords))

    return filtered
}
