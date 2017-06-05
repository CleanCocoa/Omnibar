//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import enum Omnibar.OmnibarContent

struct Suggestion {

    let requestNumber: Int
    let text: String
    let appendix: String?

    var string: String {
        return text.appending(appendix ?? "")
    }

    /// Fails to initialize if `bestFit` does not start with `searchTerm`.
    init?(bestFit: String, forSearchTerm searchTerm: String, requestNumber: Int) {

        guard let matchRange = bestFit.lowercased().range(of: searchTerm.lowercased()),
            matchRange.lowerBound == bestFit.startIndex
            else { return nil }

        let appendix = bestFit.removingSubrange(matchRange)

        self.text = searchTerm
        self.appendix = appendix
        self.requestNumber = requestNumber
    }

    init(onlySearchTerm searchTerm: String, requestNumber: Int) {

        self.text = searchTerm
        self.appendix = nil
        self.requestNumber = requestNumber
    }
}

import struct RxOmnibar.OmnibarContentResponse

extension Suggestion: OmnibarContentResponseConvertible {
    var omnibarContentResponse: OmnibarContentResponse {

        let content: OmnibarContent = {
            guard let appendix = self.appendix else {
                return .prefix(text: text)
            }

            return .suggestion(text: text, appendix: appendix)
        }()

        return OmnibarContentResponse(
            omnibarContent: content,
            requestNumber: self.requestNumber)
    }
}
