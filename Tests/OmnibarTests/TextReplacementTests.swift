//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Testing
@testable import Omnibar

@Suite("TextReplacement")
struct TextReplacementTests {

    @Test("compares equal when text and selected range both match")
    func equality() {
        #expect(
            TextReplacement(text: "Honda", selectedRange: NSRange(location: 0, length: 0))
                == TextReplacement(text: "Honda", selectedRange: NSRange(location: 0, length: 0)))
        #expect(
            TextReplacement(text: "Honda", selectedRange: NSRange(location: 0, length: 0))
                != TextReplacement(text: "Honda", selectedRange: NSRange(location: 100, length: 0)))
        #expect(
            TextReplacement(text: "Hond-b", selectedRange: NSRange(location: 0, length: 0))
                != TextReplacement(text: "Honda", selectedRange: NSRange(location: 0, length: 0)))
    }
}
