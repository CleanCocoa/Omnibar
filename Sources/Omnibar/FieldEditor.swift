//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

protocol FieldEditor {
    func replaceAllCharacters(with string: String)
    func selectRange(_ range: NSRange)
}
