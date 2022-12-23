//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import Omnibar

class OmnibarContentTests: XCTestCase {

    func testStringValue() {

        XCTAssertEqual(OmnibarContent.empty.string, "")
        XCTAssertEqual(OmnibarContent.prefix(text: "foo bar").string, "foo bar")
        XCTAssertEqual(OmnibarContent.selection(text: "selecione textual").string, "selecione textual")
        XCTAssertEqual(OmnibarContent.suggestion(text: "only text", appendix: "").string, "only text")
        XCTAssertEqual(OmnibarContent.suggestion(text: "more than text", appendix: "like this").string, "more than textlike this")
    }

    func testSelectionRange() {

        XCTAssertEqual(
            OmnibarContent.empty.selectionRange,
            NSRange(location: 0, length: 0))
        XCTAssertEqual(
            OmnibarContent.prefix(text: "foo bar").selectionRange,
            NSRange(location: ("foo bar" as NSString).length, length: 0))
        XCTAssertEqual(
            OmnibarContent.selection(text: "selecione textual").selectionRange,
            NSRange(location: 0, length: ("selecione textual" as NSString).length))
        XCTAssertEqual(
            OmnibarContent.suggestion(text: "only text", appendix: "").selectionRange,
            NSRange(location: ("only text" as NSString).length, length: 0))
        XCTAssertEqual(
            OmnibarContent.suggestion(text: "more than text", appendix: "like this").selectionRange,
            NSRange(location: ("more than text" as NSString).length,
                    length: ("like this" as NSString).length))
    }

}
