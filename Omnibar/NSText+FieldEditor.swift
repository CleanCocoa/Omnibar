//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSText: FieldEditor {
    
    func selectRange(_ range: NSRange) {

        self.selectedRange = range
    }

    func replaceAllCharacters(with string: String) {

//        guard let contentString = self.string else {
            self.string = string
//            return
//        }
//
//        // Setting .string would move the insertion point
//        let length = (contentString as NSString).length
//        let oldSelectedRange = self.selectedRange
//        replaceCharacters(
//            in: NSRange(location: 0, length: length),
//            with: string)
//        self.selectedRange = oldSelectedRange
    }
}
