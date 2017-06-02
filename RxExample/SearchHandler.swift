//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import ExampleModel

protocol SearchHandler: class {
    func search(for searchTerm: String, offerSuggestion: Bool) -> Maybe<SearchResult>
}

struct SearchResult {
    let suggestion: Suggestion?
    let results: [Word]
}
