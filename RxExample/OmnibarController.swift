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
            .flatMapLatest { change -> Maybe<Suggestion> in
                guard let searchHandler = self.searchHandler else { return .empty() }

                return RxSearchHandler(searchHandler: searchHandler)
                    .search(for: change.contentChange.text,
                            offerSuggestion: change.method == .insertion)
            }
            .map { $0.omnibarContent }
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

    func search(for searchTerm: String, offerSuggestion: Bool = false) -> Maybe<Suggestion> {

        return Observable.create { observer -> Disposable in

            var cancelled = false

            self.searchHandler.search(for: searchTerm) { (bestFit, searchTerm) in

                if !cancelled,
                    offerSuggestion,
                    let suggestion = Suggestion(bestFit: bestFit, forSearchTerm: searchTerm) {
                    observer.on(.next(suggestion))
                }

                observer.on(.completed)
            }

            return Disposables.create { cancelled = true }
        }.asMaybe()
    }
}

struct Suggestion {

    let text: String
    let appendix: String

    /// Fails to initialize if `bestFit` does not start with `searchTerm`.
    init?(bestFit: String, forSearchTerm searchTerm: String) {

        guard let matchRange = bestFit.lowercased().range(of: searchTerm.lowercased()),
            matchRange.lowerBound == bestFit.startIndex
            else { return nil }

        let appendix = bestFit.removingSubrange(matchRange)

        self.text = searchTerm
        self.appendix = appendix
    }

    var omnibarContent: OmnibarContent {
        return .suggestion(text: text, appendix: appendix)
    }
}
