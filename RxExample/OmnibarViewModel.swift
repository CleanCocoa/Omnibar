//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import RxCocoa
import RxOmnibar

struct SearchResultsViewModel {

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

import Omnibar
import ExampleModel

struct OmnibarContentViewModel {

    let wordSelectionChange: Driver<Word>
    let wordSuggestion: Driver<Suggestion>

    var omnibarContent: Driver<OmnibarContent> {

        let selection = wordSelectionChange
            .map { OmnibarContent.selection(text: $0) }
        let suggestion = wordSuggestion
            .map { $0.omnibarContent }

        return Observable
            .of(selection, suggestion)
            .merge()
            .asDriver(onErrorDriveWith: .empty())
    }
}
