//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import RxCocoa
import ExampleModel

struct SearchResultParts {

    let searchResults: Driver<SearchResult>

    var suggestion: Driver<Suggestion> {
        return searchResults
            .map({ $0.suggestion })
            .ignoreNil()
    }

    var selectWord: Driver<String?> {
        return searchResults
            .map { $0.suggestion?.string }
    }

    var words: Driver<[Word]> {
        return searchResults.map { $0.results }
    }
}
