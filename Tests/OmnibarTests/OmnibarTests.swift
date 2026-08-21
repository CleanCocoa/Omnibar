//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit
import Testing
@testable import Omnibar

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

@MainActor
@Suite("Omnibar: displaying content")
struct OmnibarDisplayTests {

    @Test("empty content clears the text")
    func emptyChangesStringValue() {
        let omnibar = Omnibar()
        omnibar.stringValue = "existing"

        omnibar.display(content: .empty)

        #expect(omnibar.stringValue == "")
    }

    @Test("empty content configures the editor")
    func emptyConfiguresEditor() {
        let omnibar = TestableOmnibar()
        let editableTextDouble = EditableTextDouble()
        omnibar.editableTextDouble = editableTextDouble

        omnibar.display(content: .empty)

        #expect(editableTextDouble.didReplace == TextReplacement(omnibarContent: .empty))
    }

    @Test("a selection replaces the text")
    func selectionChangesStringValue() {
        let omnibar = Omnibar()
        omnibar.stringValue = "existing"
        let text = "some new text"

        omnibar.display(content: .selection(text: text))

        #expect(omnibar.stringValue == text)
    }

    @Test("a selection configures the editor")
    func selectionConfiguresEditor() {
        let omnibar = TestableOmnibar()
        let editableTextDouble = EditableTextDouble()
        omnibar.editableTextDouble = editableTextDouble
        let content = OmnibarContent.selection(text: "Shnabubula")

        omnibar.display(content: content)

        #expect(editableTextDouble.didReplace == TextReplacement(omnibarContent: content))
    }

    @Test("a prefix replaces the text")
    func prefixChangesStringValue() {
        let omnibar = Omnibar()
        omnibar.stringValue = "existing"
        let text = "replacement text"

        omnibar.display(content: .prefix(text: text))

        #expect(omnibar.stringValue == text)
    }

    @Test("a prefix configures the editor")
    func prefixConfiguresEditor() {
        let omnibar = TestableOmnibar()
        let editableTextDouble = EditableTextDouble()
        omnibar.editableTextDouble = editableTextDouble
        let content = OmnibarContent.prefix(text: "this is new")

        omnibar.display(content: content)

        #expect(editableTextDouble.didReplace == TextReplacement(omnibarContent: content))
    }

    @Test("a suggestion shows text and appendix together")
    func suggestionChangesStringValue() {
        let omnibar = Omnibar()
        omnibar.stringValue = "existing"

        omnibar.display(content: .suggestion(text: "first part", appendix: ", and the rest"))

        #expect(omnibar.stringValue == "first part, and the rest")
    }

    @Test("a suggestion configures the editor")
    func suggestionConfiguresEditor() {
        let omnibar = TestableOmnibar()
        let editableTextDouble = EditableTextDouble()
        omnibar.editableTextDouble = editableTextDouble
        let content = OmnibarContent.suggestion(text: "first part", appendix: "second part")

        omnibar.display(content: content)

        #expect(editableTextDouble.didReplace == TextReplacement(omnibarContent: content))
    }
}

@MainActor
@Suite("Omnibar: movement commands")
struct OmnibarMovementTests {

    @Test(
        "forwards the movement selectors it handles",
        arguments: [
            (#selector(NSResponder.moveToBeginningOfDocument(_:)), MovementEvent.Movement.top),
            (#selector(NSResponder.moveToEndOfDocument(_:)), .bottom),
            (#selector(NSResponder.moveDown(_:)), .down),
            (#selector(NSResponder.moveUp(_:)), .up),
        ])
    func forwardsMovement(commandSelector: Selector, movement: MovementEvent.Movement) {
        let omnibar = Omnibar()
        var events: [MovementEvent] = []
        let observation = omnibar.observe {
            guard case let .movement(event) = $0 else { return }
            events.append(event)
        }

        let didHandle = omnibar.doOmnibarCommand(commandSelector: commandSelector)

        #expect(didHandle)
        #expect(events == [MovementEvent(movement: movement)])
        withExtendedLifetime(observation) { }
    }
}
