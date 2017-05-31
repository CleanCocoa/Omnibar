//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

protocol TextChangeDelegate: class {
    func omnibarTextField(_ omnibarTextField: OmnibarTextField, willChange textChange: TextFieldTextChange)
}

class OmnibarTextField: NSTextField {

    weak var textChangeDelegate: TextChangeDelegate?
}

// MARK: - Typing

// A `NSTextField` is the delegate of the field editor by
// default if it conforms to `NSTextViewDelegate`.

extension OmnibarTextField: NSTextViewDelegate {

    public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {

        // `replacementString` is `nil` on attribute changes only,
        // but equals "" on deletion.
        guard let replacementString = replacementString else { return true }
        guard let oldText = textView.string else { preconditionFailure("NSTextView is supposed to have non-nil string") }

        let method: TextFieldTextChange.Method = {
            let insertionLength = (replacementString as NSString).length
            let affectedLength = affectedCharRange.length

            if insertionLength < 1 && affectedLength > 0 { return .deletion }

            return .insertion
        }()

        let textChange = TextFieldTextChange(
            oldText: oldText,
            patch: TextFieldTextPatch(
                string: replacementString,
                range: affectedCharRange),
            method: method)
        textChangeDelegate?.omnibarTextField(self, willChange: textChange)

        return true
    }
}
