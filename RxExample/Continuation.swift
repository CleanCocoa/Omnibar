//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

struct Continuation {

    let text: String
    let appendix: String
    let requestNumber: Int
}

import struct RxOmnibar.OmnibarContentResponse
import struct RxOmnibar.RxOmnibarContentChange


extension Continuation: OmnibarContentResponseConvertible {

    var omnibarContentResponse: OmnibarContentResponse {
        return OmnibarContentResponse(
            omnibarContent: .suggestion(text: text, appendix: appendix),
            requestNumber: requestNumber)
    }
}

extension Continuation {

    init?(change: RxOmnibarContentChange) {
        switch change.contentChange {
        case let .continuation(text: text, remainingAppendix: appendix):
            self.init(
                text: text,
                appendix: appendix,
                requestNumber: change.requestNumber)

        case .replacement: return nil
        }
    }
}
