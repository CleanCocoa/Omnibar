//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import RxCocoa
import struct RxOmnibar.RxOmnibarContentChange

struct SearchViewModel {

    let typedSearches: Observable<RxOmnibarContentChange>
    let programmaticSearches: Observable<String>

    var searches: Observable<Search> {

        let typed = typedSearches.map { change in
            Search(searchTerm: change.contentChange.text,
                   requestSuggestion: change.method == .appending,
                   requestNumber: change.requestNumber) }
        let programmatic = programmaticSearches.map { term in
            Search(searchTerm: term,
                   requestSuggestion: false) }
        
        return Observable.of(typed, programmatic).merge()
    }
}
