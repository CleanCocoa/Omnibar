//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

public class OmnibarTextField: DelegatableTextField {

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
        guard let replacement = replacementString else {
            return super.del_textView(textView, shouldChangeTextIn: affectedCharRange, replacementString: replacementString)
        }

        let oldText = textView.string
        let method = ChangeMethod(
            original: oldText as NSString,
            replacement: replacement as NSString,
            affectedRange: affectedCharRange)

        self.cachedTextFieldChange = TextFieldTextChange(
            oldText: oldText,
            patch: TextFieldTextPatch(
                string: replacement,
                range: affectedCharRange),
            method: method)

        return super.del_textView(textView, shouldChangeTextIn: affectedCharRange, replacementString: replacementString)
    }
}
