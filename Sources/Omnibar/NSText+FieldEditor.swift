//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSText: FieldEditor {
    
    func selectRange(_ range: NSRange) {

        self.selectedRange = range
    }

    func replaceAllCharacters(with string: String) {

        self.string = string
    }
}
