@testable import Omnibar

class FieldEditorDouble: FieldEditor {
    
    var didReplaceAllCharacters: String?
    func replaceAllCharacters(with string: String) {
        didReplaceAllCharacters = string
    }

    var didSelectRange: NSRange?
    func selectRange(_ range: NSRange) {
        didSelectRange = range
    }
}
