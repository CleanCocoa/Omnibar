//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar
import RxSwift
import RxOmnibar
import ExampleModel

protocol SearchHandler: class {
    func search(
        for searchTerm: String,
        suggestionCallback: ((_ bestFit: String, _ searchTerm: String) -> Void)?)
}

protocol SelectsResult: class {
    func selectNext()
    func selectPrevious()
}

class OmnibarController: NSViewController {

    weak var searchHandler: SearchHandler?
    weak var selectionHandler: SelectsResult?

    var omnibar: Omnibar! { return self.view as? Omnibar }

    let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        let movementObserver = AnyObserver { [weak self] (event: Event<MoveSelection>) in
            guard case .next(let movement) = event else { return }
            switch movement {
            case .next: self?.selectionHandler?.selectNext()
            case .previous: self?.selectionHandler?.selectPrevious()
            }
        }

        omnibar.rx.contentChange
            .flatMapLatest { change -> Maybe<(String, String)> in
                guard let searchHandler = self.searchHandler else { return .empty() }

                return RxSearchHandler(searchHandler: searchHandler)
                    .search(for: change.contentChange.text,
                            offerSuggestion: change.method == .insertion)
            }
            .map(suggestion(bestFit:forSearchTerm:))
            .bind(to: omnibar.rx.content)
            .disposed(by: disposeBag)

        omnibar.rx.moveSelection
            .bind(to: movementObserver)
            .disposed(by: disposeBag)
    }
}

extension OmnibarController: SelectsWord {

    func select(word: Word) {

        omnibar.rx.content.onNext(.selection(text: word))
    }
}

class RxSearchHandler {

    let searchHandler: SearchHandler

    init(searchHandler: SearchHandler) {
        self.searchHandler = searchHandler
    }

    func search(for searchTerm: String, offerSuggestion: Bool = false) -> Maybe<(String, String)> {

        return Observable.create { observer -> Disposable in

            var cancelled = false

            self.searchHandler.search(for: searchTerm) { (bestFit, suggestion) in

                if !cancelled && offerSuggestion {
                    observer.on(.next((bestFit, suggestion)))
                }

                observer.on(.completed)
            }

            return Disposables.create { cancelled = true }
        }.asMaybe()
    }
}

fileprivate func suggestion(bestFit: String, forSearchTerm searchTerm: String) -> OmnibarContent {

    guard let matchRange = bestFit.lowercased().range(of: searchTerm.lowercased()),
        matchRange.lowerBound == bestFit.startIndex
        else { preconditionFailure("display(bestFit:forSearchTerm:) must be called with `searchTerm` starting `bestFit`") }

    let appendix = bestFit.removingSubrange(matchRange)

    return .suggestion(text: searchTerm, appendix: appendix)
}
