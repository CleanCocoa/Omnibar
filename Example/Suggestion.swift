//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar

struct Suggestion {
    let text: String
    let appendix: String

    /// Fails to initialize if `bestFit` does not start with `searchTerm`.
    init?(bestFit: String, forSearchTerm searchTerm: String) {
        guard let matchRange = bestFit.prefixRange(of: searchTerm, options: .caseInsensitive)
        else { return nil }

        let appendix = bestFit.removingSubrange(matchRange)

        self.text = searchTerm
        self.appendix = appendix
    }

    var omnibarContent: OmnibarContent {
        return .suggestion(text: text, appendix: appendix)
    }
}
