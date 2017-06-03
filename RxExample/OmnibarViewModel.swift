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

import Omnibar
import ExampleModel

struct Continuation {
    let text: String
    let appendix: String

    var omnibarContent: OmnibarContent {
        return .suggestion(text: text, appendix: appendix)
    }
}

extension Continuation {
    init?(change: RxOmnibarContentChange) {
        switch change.contentChange {
        case .replacement: return nil
        case let .continuation(text: text, remainingAppendix: appendix):
            self.init(text: text, appendix: appendix)
        }
    }
}

struct OmnibarContentViewModel {

    let wordSelectionChange: Driver<Word>
    let wordSuggestion: Driver<Suggestion>
    let continuation: Driver<Continuation>

    var omnibarContent: Driver<OmnibarContent> {

        let selection = self.wordSelectionChange
            .map { OmnibarContent.selection(text: $0) }
        let suggestion = self.wordSuggestion
            .map { $0.omnibarContent }
        let continuation = self.continuation
            .map { $0.omnibarContent }

        return Observable
            .of(selection, suggestion, continuation)
            .merge()
            .asDriver(onErrorDriveWith: .empty())
    }
}
