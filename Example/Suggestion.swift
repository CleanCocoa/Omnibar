//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Omnibar

fileprivate extension String {
    /// Returns the range of `prefix` in `self` if it is matched at the start.
    func prefixRange(
        of prefix: String,
        options: CompareOptions = []
    ) -> Range<Index>? {
        guard let matchRange = self.range(of: prefix, options: options),
              matchRange.lowerBound == self.startIndex
        else { return nil }
        return matchRange
    }

    /// Returns a new string in which the characters in `range` of the string are removed.
    func removingSubrange(_ range: Range<Index>) -> String {
        return self.replacingCharacters(in: range, with: "")
    }
}

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
