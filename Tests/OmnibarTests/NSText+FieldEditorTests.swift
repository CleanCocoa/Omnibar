//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import Omnibar

class NSText_FieldEditorTests: XCTestCase {

    func testSelectRange_ChangesSelectedRange() {

        let text = NSText()
        text.string = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua." // Long enough string
        text.selectedRange = NSRange(location: 20, length: 10)
        let newRange = NSRange(location: 3, length: 4)

        (text as FieldEditor).selectRange(newRange)

        XCTAssertEqual(text.selectedRange, newRange)
    }

    func testReplaceAllCharacters_StartingEmpty_SetsStringValue() {

        let text = NSText()
        let newString = "this is the new stuff"

        (text as FieldEditor).replaceAllCharacters(with: newString)

        XCTAssertEqual(text.string, newString)
    }

    func testReplaceAllCharacters_StartingEmpty_MovesInsertionPointToEndOfText() {

        let text = NSText()
        let newString = "inserted"

        (text as FieldEditor).replaceAllCharacters(with: newString)

        XCTAssertEqual(
            text.selectedRange,
            NSRange(location: (newString as NSString).length, length: 0))
    }

    func testReplaceAllCharacters_StartingWithText_ReplacesStringValue() {

        let text = NSText()
        text.string = "old shite"
        let newString = "new shizz"

        (text as FieldEditor).replaceAllCharacters(with: newString)

        XCTAssertEqual(text.string, newString)
    }

//    func testReplaceAllCharacters_StartingWithText_KeepsInsertionPointLocation() {
//
//        let text = NSText()
//        text.string = "the old text"
//        let initialSelectedRange = NSRange(location: 5, length: 3)
//        text.selectedRange = initialSelectedRange
//        let newString = "very much new text"
//
//        (text as FieldEditor).replaceAllCharacters(with: newString)
//
//        XCTAssertEqual(text.selectedRange, initialSelectedRange)
//    }

}
