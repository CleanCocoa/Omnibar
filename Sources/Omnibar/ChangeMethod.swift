//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

public enum ChangeMethod {

    /// Deletion anywhere in the Omnibar.
    case deletion

    /// Append (or replace) text up to the end of the Omnibar's content.
    ///
    /// Before:
    ///
    ///     "lorem ips[o facto]"
    ///                ^^^^^^^--- selected
    ///
    /// After type-replacing at the end:
    ///
    ///     "lorem ipsum[|]"
    ///               ÎÎ ^--- insertion point
    ///               ``--- typed
    case appending

    /// Insert text in the middle or at the beginning, but with still more text following after.
    ///
    /// Examples:
    ///
    ///    Before: "[|] ipsum"
    ///    After:  "lorem[|] ipsum"
    ///                   ^--- insertion point
    case insertion

    init(original: NSString, replacement: NSString, affectedRange: NSRange) {

        self = {
            let insertionLength = replacement.length
            let affectedLength = affectedRange.length

            if insertionLength < 1 && affectedLength > 0 { return .deletion }

            let replacementEnd = affectedRange.location + affectedRange.length
            if replacementEnd == original.length { return .appending }

            return .insertion
        }()
    }
}
