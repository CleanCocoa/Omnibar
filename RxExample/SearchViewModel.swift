//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import struct RxOmnibar.RxOmnibarContentChange

struct SearchViewModel {

    let contentChange: Observable<RxOmnibarContentChange>
    let programmaticSearch: Observable<String>

    var search: Observable<Search> {

        let content = contentChange.map { change in
            Search(searchTerm: change.contentChange.text,
                   requestSuggestion: change.method == .appending) }
        let search = programmaticSearch.map { term in
            Search(searchTerm: term,
                   requestSuggestion: false) }
        
        return Observable.of(content, search).merge()
    }
}
