//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

protocol EditableText {
    func replace(replacement: TextReplacement)
}

extension EditableText where Self: NSControl {
    func replace(replacement: TextReplacement) {
        // Do not set `stringValue` in an active editing session because that "aborts all editing before setting the value." (See docs.)
        // Note that `currentEditor()` returns `NSText` for legacy reasons, but:  "The field editor is a single NSTextView object that is shared among all the controls in a window for light text-editing needs."
        guard let fieldEditor = self.currentEditor() as? NSTextView else {
            self.stringValue = replacement.text
            return
        }

        // Set `NSText.string` directly instead to *not* handle this as if the user typed the text.
        // (Usually, you will want to perform a change by bracketing it in `shouldChangeText(in:replacementString:)` before, `didChangeText()` after the replacement, and perform the change on `NSTextStorage` directly.)
        fieldEditor.string = replacement.text
        fieldEditor.selectedRange = replacement.selectedRange
    }
}
