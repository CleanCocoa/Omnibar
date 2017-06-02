//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar
import RxSwift
import RxOmnibar
import ExampleModel

protocol SearchHandler: class {
    func search(for searchTerm: String, offerSuggestion: Bool)
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

        let searchHandlerObserver = AnyObserver { [weak self] (event: Event<RxOmnibarContentChange>)  in
            guard case .next(let change) = event else { return }
            self?.searchHandler?.search(
                for: change.contentChange.text,
                offerSuggestion: change.method == .insertion)
        }

        let movementObserver = AnyObserver { [weak self] (event: Event<MoveSelection>) in
            guard case .next(let movement) = event else { return }
            switch movement {
            case .next: self?.selectionHandler?.selectNext()
            case .previous: self?.selectionHandler?.selectPrevious()
            }
        }
        
        omnibar.rx.contentChange
            .bind(to: searchHandlerObserver)
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

extension OmnibarController: DisplaysSuggestion {

    func display(bestFit: String, forSearchTerm searchTerm: String) {

        guard let matchRange = bestFit.lowercased().range(of: searchTerm.lowercased()),
            matchRange.lowerBound == bestFit.startIndex
            else { preconditionFailure("display(bestFit:forSearchTerm:) must be called with `searchTerm` starting `bestFit`") }

        let appendix = bestFit.removingSubrange(matchRange)

        omnibar.rx.content.onNext(.suggestion(text: searchTerm, appendix: appendix))
    }
}
