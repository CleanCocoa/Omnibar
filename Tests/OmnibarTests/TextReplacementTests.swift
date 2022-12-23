//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import Omnibar

class TextReplacementTests: XCTestCase {

    func testEquality() {

        XCTAssertEqual(
            TextReplacement(text: "Honda", selectedRange: NSRange(location: 0, length: 0)),
            TextReplacement(text: "Honda", selectedRange: NSRange(location: 0, length: 0)))
        XCTAssertNotEqual(
            TextReplacement(text: "Honda", selectedRange: NSRange(location: 0, length: 0)),
            TextReplacement(text: "Honda", selectedRange: NSRange(location: 100, length: 0)))
        XCTAssertNotEqual(
            TextReplacement(text: "Hond-b", selectedRange: NSRange(location: 0, length: 0)),
            TextReplacement(text: "Honda", selectedRange: NSRange(location: 0, length: 0)))
    }

}
