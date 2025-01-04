//  Copyright © 2025 Christian Tietze. All rights reserved. Distributed under the MIT License.

extension String {
    /// Returns a new string in which the characters in `range` of the string are removed.
    public func removingSubrange(_ range: Range<Index>) -> String {
        return self.replacingCharacters(in: range, with: "")
    }
}
