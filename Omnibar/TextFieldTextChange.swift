//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import struct Foundation.NSRange

public struct TextFieldTextChange {

    public let oldText: String
    public let patch: TextFieldTextPatch
    public let method: ChangeMethod

    public init(oldText: String, patch: TextFieldTextPatch, method: ChangeMethod) {

        self.oldText = oldText
        self.patch = patch
        self.method = method
    }

    public var result: String {

        let replacementRange: Range<String.Index> = {
            let rangeStart = oldText.index(
                oldText.startIndex,
                offsetBy: patch.range.location,
                limitedBy: oldText.endIndex)
                ?? oldText.endIndex
            let rangeEnd = oldText.index(
                rangeStart,
                offsetBy: patch.range.length,
                limitedBy: oldText.endIndex)
                ?? oldText.endIndex
            return rangeStart..<rangeEnd
        }()

        return oldText.replacingCharacters(
            in: replacementRange,
            with: patch.string)
    }
}

public struct TextFieldTextPatch {
    public let string: String
    public let range: NSRange
    
    public init(string: String, range: NSRange) {
        self.string = string
        self.range = range
    }
}

extension TextFieldTextChange {

    public init(oldText: String, patch: String, range: NSRange, method: ChangeMethod) {

        self.oldText = oldText
        self.patch = TextFieldTextPatch(string: patch, range: range)
        self.method = method
    }
}
