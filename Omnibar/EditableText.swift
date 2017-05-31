//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

protocol EditableText {
    /// The current `FieldEditor` to read from and write into.
    ///
    /// - returns: A `FieldEditor` instance for the current
    ///   editing session, `nil` when no editing session
    ///   is active.
    func fieldEditor() -> FieldEditor?

    func replace(replacement: TextReplacement)
}

extension EditableText where Self: NSControl {

    func fieldEditor() -> FieldEditor? {
        return self.currentEditor()
    }

    func replace(replacement: TextReplacement) {

        guard let fieldEditor = self.fieldEditor() else {
            self.stringValue = replacement.text
            return
        }

        fieldEditor.replaceAllCharacters(with: replacement.text)
        fieldEditor.selectRange(replacement.selectedRange)
    }
}
