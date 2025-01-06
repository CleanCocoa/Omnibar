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

fileprivate class EditableTextDouble: TextReplaceable {
    var didReplace: TextReplacement?
    func replaceText(replacement: TextReplacement) {
        didReplace = replacement
    }
}

fileprivate class TestableOmnibar: Omnibar {
    var editableTextDouble: TextReplaceable?
    override var editableText: TextReplaceable {
        return editableTextDouble ?? super.editableText
    }
}


// MARK: - Display Content

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


// MARK: - Arrow keys

extension OmnibarTests {
    func testControlCommand_MoveToBeginning_CallsMovementHandler() {
        let omnibar = Omnibar()
        let movementExpectation = expectation(description: "movement event forwarding")
        omnibar.moveFromOmnibar = .init(handler: { event in
            XCTAssertEqual(event, .init(movement: .top))
            movementExpectation.fulfill()
        })

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveToBeginningOfDocument(_:)))

        XCTAssert(didHandle)
        wait(for: [movementExpectation])
    }

    func testControlCommand_MoveToEnd_CallsMovementHandler() {
        let omnibar = Omnibar()
        let movementExpectation = expectation(description: "movement event forwarding")
        omnibar.moveFromOmnibar = .init(handler: { event in
            XCTAssertEqual(event, .init(movement: .bottom))
            movementExpectation.fulfill()
        })

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveToEndOfDocument(_:)))

        XCTAssert(didHandle)
        wait(for: [movementExpectation])
    }

    func testControlCommand_MoveDown_CallsMovementHandler() {
        let omnibar = Omnibar()
        let movementExpectation = expectation(description: "movement event forwarding")
        omnibar.moveFromOmnibar = .init(handler: { event in
            XCTAssertEqual(event, .init(movement: .down))
            movementExpectation.fulfill()
        })

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveDown(_:)))

        XCTAssert(didHandle)
        wait(for: [movementExpectation])
    }

    func testControlCommand_MoveUp_CallsMovementHandler() {
        let omnibar = Omnibar()
        let movementExpectation = expectation(description: "movement event forwarding")
        omnibar.moveFromOmnibar = .init(handler: { event in
            XCTAssertEqual(event, .init(movement: .up))
            movementExpectation.fulfill()
        })

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveUp(_:)))

        XCTAssert(didHandle)
        wait(for: [movementExpectation])
    }
}
