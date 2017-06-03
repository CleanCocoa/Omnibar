//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import ExampleModel

protocol SearchHandler: class {
    func filter(search: Search) -> Maybe<SearchResult>
}

struct Search {
    let searchTerm: String
    let requestSuggestion: Bool
}

struct SearchResult {
    let suggestion: Suggestion?
    let results: [Word]
}
