//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import Omnibar

class OmnibarTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
}


// MARK: Displaying OmnibarContent

fileprivate class EditableTextDouble: EditableText {
    func fieldEditor() -> FieldEditor? { return nil }

    var didReplace: TextReplacement?
    func replace(replacement: TextReplacement) {
        didReplace = replacement
    }
}

fileprivate class TestableOmnibar: Omnibar {
    var editableTextDouble: EditableText?
    override var editableText: EditableText {
        return editableTextDouble ?? super.editableText
    }
}

extension OmnibarTests {

    func testDisplayContent_Empty_ChangesStringValue() {

        let omnibar = Omnibar()
        omnibar.stringValue = "existing"

        omnibar.display(content: .empty)

        XCTAssertEqual(omnibar.stringValue, "")
    }

    func testDisplayContent_Empty_ConfiguresEditor() {

        let omnibar = TestableOmnibar()
        let editableTextDouble = EditableTextDouble()
        omnibar.editableTextDouble = editableTextDouble

        omnibar.display(content: .empty)

        XCTAssertEqual(
            editableTextDouble.didReplace,
            TextReplacement(omnibarContent: .empty))
    }

    func testDisplayContent_Selection_ChangesStringValue() {

        let omnibar = Omnibar()
        omnibar.stringValue = "existing"
        let text = "some new text"

        omnibar.display(content: .selection(text: text))

        XCTAssertEqual(omnibar.stringValue, text)
    }

    func testDisplayContent_Selection_ConfiguresEditor() {

        let omnibar = TestableOmnibar()
        let editableTextDouble = EditableTextDouble()
        omnibar.editableTextDouble = editableTextDouble
        let content = OmnibarContent.selection(text: "Shnabubula")

        omnibar.display(content: content)

        XCTAssertEqual(
            editableTextDouble.didReplace,
            TextReplacement(omnibarContent: content))
    }

    func testDisplayContent_Prefix_ChangesStringValue() {

        let omnibar = Omnibar()
        omnibar.stringValue = "existing"
        let text = "replacement text"

        omnibar.display(content: .prefix(text: text))

        XCTAssertEqual(omnibar.stringValue, text)
    }

    func testDisplayContent_Prefix_ConfiguresEditor() {

        let omnibar = TestableOmnibar()
        let editableTextDouble = EditableTextDouble()
        omnibar.editableTextDouble = editableTextDouble
        let content = OmnibarContent.prefix(text: "this is new")

        omnibar.display(content: content)

        XCTAssertEqual(
            editableTextDouble.didReplace,
            TextReplacement(omnibarContent: content))
    }

    func testDisplayContent_Suggestion_ChangesStringValue() {

        let omnibar = Omnibar()
        omnibar.stringValue = "existing"
        let text = "first part"
        let appendix = ", and the rest"

        omnibar.display(content: .suggestion(text: text, appendix: appendix))

        XCTAssertEqual(omnibar.stringValue, "first part, and the rest")
    }

    func testDisplayContent_Suggestion_ConfiguresEditor() {

        let omnibar = TestableOmnibar()
        let editableTextDouble = EditableTextDouble()
        omnibar.editableTextDouble = editableTextDouble
        let content = OmnibarContent.suggestion(text: "first part", appendix: "second part")

        omnibar.display(content: content)

        XCTAssertEqual(
            editableTextDouble.didReplace,
            TextReplacement(omnibarContent: content))
    }

}


// MARK: Arrow keys

extension OmnibarTests {

    class SelectionDelegateDouble: OmnibarSelectionDelegate {
        var didSelectPrevious: Omnibar?
        func omnibarSelectPrevious(_ omnibar: Omnibar) {
            didSelectPrevious = omnibar
        }

        var didSelectNext: Omnibar?
        func omnibarSelectNext(_ omnibar: Omnibar) {
            didSelectNext = omnibar
        }
    }

    var irrelevantControl: NSControl { return NSControl() }
    var irrelevantTextView: NSTextView { return NSTextView() }

    func testControlCommand_MoveDown_CallsDelegate() {

        let omnibar = Omnibar()
        let double = SelectionDelegateDouble()
        omnibar.selectionDelegate = double

        let didHandle = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.moveDown(_:)))

        XCTAssert(didHandle)
        XCTAssert(double.didSelectNext === omnibar)
        XCTAssertNil(double.didSelectPrevious)
    }

    func testControlCommand_MoveUp_CallsDelegate() {

        let omnibar = Omnibar()
        let double = SelectionDelegateDouble()
        omnibar.selectionDelegate = double

        let didHandle = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.moveUp(_:)))

        XCTAssert(didHandle)
        XCTAssertNil(double.didSelectNext)
        XCTAssert(double.didSelectPrevious === omnibar)
    }

}
