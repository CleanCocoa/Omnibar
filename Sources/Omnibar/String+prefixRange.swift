//  Copyright © 2025 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

extension String {
    /// Returns the range of `prefix` in `self` if it is matched at the start.
    public func prefixRange(
        of prefix: String,
        options: CompareOptions = []
    ) -> Range<Index>? {
        guard let matchRange = self.range(of: prefix, options: options),
              matchRange.lowerBound == self.startIndex
        else { return nil }
        return matchRange
    }
}
