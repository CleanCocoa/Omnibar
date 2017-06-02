//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar
import RxSwift
import RxOmnibar
import ExampleModel

protocol SearchHandler: class {
    func search(for searchTerm: String, offerSuggestion: Bool) -> Maybe<SearchResult>
}

protocol SelectsResult: class {
    func selectNext()
    func selectPrevious()
}

class SearchController {

    weak var selectionHandler: SelectsResult?

    let omnibar: Omnibar
    fileprivate let disposeBag = DisposeBag()

    init(omnibar: Omnibar) {

        self.omnibar = omnibar

        wireOmnibar()
    }

    private func wireOmnibar() {

        let movementObserver = AnyObserver { [weak self] (event: Event<MoveSelection>) in
            guard case .next(let movement) = event else { return }
            switch movement {
            case .next: self?.selectionHandler?.selectNext()
            case .previous: self?.selectionHandler?.selectPrevious()
            }
        }

        omnibar.rx.moveSelection
            .bind(to: movementObserver)
            .disposed(by: disposeBag)
    }
}

extension SearchController: SelectsWord {

    func select(word: Word) {

        omnibar.rx.content.onNext(.selection(text: word))
    }
}
