//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import RxSwift
import RxCocoa
import RxOmnibar
import Omnibar
import ExampleModel

protocol OmnibarContentResponseConvertible {
    var omnibarContentResponse: OmnibarContentResponse { get }
}

protocol OmnibarContentConvertible {
    var omnibarContent: OmnibarContent { get }
}

struct OmnibarViewModel {

    let selections: Driver<Selection>
    let suggestions: Driver<Suggestion>
    let continuations: Driver<Continuation>

    var omnibarContent: Driver<OmnibarContent> {

        let selections = self.selections.map { $0.omnibarContent }

        return selections.asDriver(onErrorDriveWith: .empty())
    }

    var omnibarContentResponse: Driver<OmnibarContentResponse> {

        let continuations = self.continuations.map { $0.omnibarContentResponse }
        let suggestions = self.suggestions.map { $0.omnibarContentResponse }

        return Observable
            .of(continuations, suggestions)
            .merge()
            .asDriver(onErrorDriveWith: .empty())
    }
}
