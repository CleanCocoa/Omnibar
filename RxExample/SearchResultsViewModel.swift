//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import RxCocoa
import RxOmnibar

struct SearchResultsViewModel {

    let searchHandler: SearchHandler
    let contentChange: Observable<RxOmnibarContentChange>
    let programmaticSearch: Observable<String>

    func searchResults() -> Observable<SearchResult> {

        let content = contentChange.map { change in (change.contentChange.text, change.method == .appending) }
        let search = programmaticSearch.map { term in (term, false) }
        let combined = Observable.of(content, search).merge()

        return combined
            .flatMapLatest { (searchTerm, offerSuggestion) -> Maybe<SearchResult> in
                return self.searchHandler.search(
                    for: searchTerm,
                    offerSuggestion: offerSuggestion)
        }
    }
}
