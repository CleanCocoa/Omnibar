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

    let selection: Driver<Selection>
    let suggestion: Driver<Suggestion>
    let continuation: Driver<Continuation>

    var omnibarContent: Driver<OmnibarContent> {

        let selection = self.selection.map { $0.omnibarContent }
        let suggestion = self.suggestion.map { $0.omnibarContent }
        let continuation = self.continuation.map { $0.omnibarContent }

        return Observable
            .of(selection, suggestion, continuation)
            .merge()
            .asDriver(onErrorDriveWith: .empty())
    }
}
