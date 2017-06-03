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

import RxOmnibar

extension SearchResultParts {
    init(
        typedSearches: Observable<RxOmnibarContentChange>,
        programmaticSearches: Observable<String>,
        wordsModels: Observable<WordsModel>
        ) {

        let searches = SearchViewModel(
            typedSearches: typedSearches.asObservable(),
            programmaticSearches: programmaticSearches)
            .searches
        let filterViewModel = Filter(
            searches: searches,
            wordsModels: wordsModels)
        let searchResults = filterViewModel
            .searchResults
            .asDriver(onErrorDriveWith: .empty())
        
        self.init(searchResults: searchResults)
    }
}
