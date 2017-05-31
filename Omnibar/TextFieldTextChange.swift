//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import struct Foundation.NSRange

struct TextFieldTextChange {

    enum Method {
        case deletion, insertion
    }

    let oldText: String
    let patch: TextFieldTextPatch
    let method: Method

    var result: String {

        let replacementRange: Range<String.Index> = {
            let rangeStart = oldText.index(
                oldText.startIndex,
                offsetBy: patch.range.location)
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

struct TextFieldTextPatch {
    let string: String
    let range: NSRange
}

extension TextFieldTextChange {
    init(oldText: String, patch: String, range: NSRange, method: Method) {
        self.oldText = oldText
        self.patch = TextFieldTextPatch(string: patch, range: range)
        self.method = method
    }
}
