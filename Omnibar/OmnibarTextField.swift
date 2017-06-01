//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class OmnibarTextField: NSTextField {

    fileprivate var cachedTextFieldChange: TextFieldTextChange?
}

// MARK: - Typing

// A `NSTextField` is the delegate of the field editor by
// default if it conforms to `NSTextViewDelegate`.

extension OmnibarTextField: NSTextViewDelegate {

    func popTextFieldChange() -> TextFieldTextChange? {

        let value = cachedTextFieldChange
        cachedTextFieldChange = nil
        return value
    }

    public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {

        // `replacementString` is `nil` on attribute changes only,
        // but equals "" on deletion.
        guard let replacementString = replacementString else { return true }
        guard let oldText = textView.string else { preconditionFailure("NSTextView is supposed to have non-nil string") }

        let method: ChangeMethod = {
            let insertionLength = (replacementString as NSString).length
            let affectedLength = affectedCharRange.length

            if insertionLength < 1 && affectedLength > 0 { return .deletion }

            return .insertion
        }()

        self.cachedTextFieldChange = TextFieldTextChange(
            oldText: oldText,
            patch: TextFieldTextPatch(
                string: replacementString,
                range: affectedCharRange),
            method: method)

        return true
    }
}
