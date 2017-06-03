//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import RxCocoa
import RxOmnibar
import ExampleModel

struct AppViewModel {

    struct OmnibarInput {
        struct SearchInput {
            let typedSearches: Driver<RxOmnibarContentChange>
            let programmaticSearches: Observable<String>
            let wordsModels: Observable<WordsModel>
        }

        struct SelectionInput {
            let wordSelections: Driver<Word>
        }
    }

    func transform(
        searchInput: OmnibarInput.SearchInput,
        selectionInput: OmnibarInput.SelectionInput
        ) -> (OmnibarViewModel, SearchResultParts) {

        let resultParts = SearchResultParts(searchInput: searchInput)

        let omnibarViewModel: OmnibarViewModel = {
            let selections = selectionInput.wordSelections
                .map(Selection.init(word:))
            let suggestions = resultParts.suggestion
            let continuations = searchInput.typedSearches
                .map(Continuation.init(change:))
                .ignoreNil()

            return OmnibarViewModel(
                selections: selections,
                suggestions: suggestions,
                continuations: continuations)
        }()

        return (omnibarViewModel, resultParts)
    }
}

extension SearchResultParts {
    init(searchInput: AppViewModel.OmnibarInput.SearchInput) {
        self.init(
            typedSearches: searchInput.typedSearches.asObservable(),
            programmaticSearches: searchInput.programmaticSearches,
            wordsModels: searchInput.wordsModels)
    }
}
