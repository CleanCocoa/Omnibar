//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar

struct Continuation {

    let text: String
    let appendix: String
}

extension Continuation: OmnibarContentConvertible {

    var omnibarContent: OmnibarContent {
        return .suggestion(text: text, appendix: appendix)
    }
}

import RxOmnibar

extension Continuation {

    init?(change: RxOmnibarContentChange) {
        switch change.contentChange {
        case .replacement: return nil
        case let .continuation(text: text, remainingAppendix: appendix):
            self.init(text: text, appendix: appendix)
        }
    }
}
