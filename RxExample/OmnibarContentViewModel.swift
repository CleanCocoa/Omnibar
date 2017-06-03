//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import RxCocoa
import RxOmnibar
import Omnibar
import ExampleModel

protocol OmnibarContentConvertible {

    var omnibarContent: OmnibarContent { get }
}

struct OmnibarViewModel {

    let selections: Driver<Selection>
    let suggestions: Driver<Suggestion>
    let continuations: Driver<Continuation>

    var omnibarContents: Driver<OmnibarContent> {

        let selections = self.selections.map { $0.omnibarContent }
        let suggestions = self.suggestions.map { $0.omnibarContent }
        let continuations = self.continuations.map { $0.omnibarContent }

        return Observable
            .of(selections, suggestions, continuations)
            .merge()
            .asDriver(onErrorDriveWith: .empty())
    }
}
