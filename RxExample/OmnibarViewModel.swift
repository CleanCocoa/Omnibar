//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import RxCocoa
import RxOmnibar

struct OmnibarViewModel {

    let searchHandler: SearchHandler
    let contentChange: Observable<RxOmnibarContentChange>

    func searchResults() -> Observable<SearchResult> {

        return contentChange
            .flatMapLatest { change -> Maybe<SearchResult> in
                return self.searchHandler.search(
                    for: change.contentChange.text,
                    offerSuggestion: change.method == .insertion)
            }
    }
}
