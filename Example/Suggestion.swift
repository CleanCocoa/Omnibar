//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Omnibar

struct Suggestion {
    let text: String
    let appendix: String

    /// Fails to initialize if `bestFit` does not start with `searchTerm`.
    init?(bestFit: String, forSearchTerm searchTerm: String) {
        guard let matchRange = bestFit.range(
            of: searchTerm,
            options: [.caseInsensitive, .anchored])
        else { return nil }

        self.text = searchTerm
        self.appendix = String(bestFit[matchRange.upperBound...])
    }

    var omnibarContent: OmnibarContent {
        return .suggestion(text: text, appendix: appendix)
    }
}
