//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import Omnibar

class OmnibarContentTests: XCTestCase {

    func testStringValue() {

        XCTAssertEqual(OmnibarContent.prefix(text: "foo bar").string, "foo bar")
        XCTAssertEqual(OmnibarContent.selection(text: "selecione textual").string, "selecione textual")
        XCTAssertEqual(OmnibarContent.suggestion(text: "only text", appendix: "").string, "only text")
        XCTAssertEqual(OmnibarContent.suggestion(text: "more than text", appendix: "like this").string, "more than textlike this")
    }
}
