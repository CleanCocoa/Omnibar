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

        // `replacementString` is `nil` on attribute changes only, which we ignore,
        // but equals "" on deletion.
        if let replacement = replacementString {
            self.cacheTextFieldChange(
                textView: textView,
                shouldChangeTextIn: affectedCharRange,
                replacementString: replacement)
        }

        return super.del_textView(textView, shouldChangeTextIn: affectedCharRange, replacementString: replacementString)
    }

    private func cacheTextFieldChange(textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String) {

        let oldText = textView.string
        let method = ChangeMethod(
            original: oldText as NSString,
            replacement: replacementString as NSString,
            affectedRange: affectedCharRange)

        self.cachedTextFieldChange = TextFieldTextChange(
            oldText: oldText,
            patch: TextFieldTextPatch(
                string: replacementString,
                range: affectedCharRange),
            method: method)
    }
}
