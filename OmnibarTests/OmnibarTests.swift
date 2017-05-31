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

extension OmnibarTests {

    func testDisplayContent_Empty_ChangesStringValue() {

        let omnibar = Omnibar()
        omnibar.stringValue = "existing"

        omnibar.display(content: .empty)

        XCTAssertEqual(omnibar.stringValue, "")
    }

    func testDisplayContent_Selection_ChangesStringValue() {

        let omnibar = Omnibar()
        omnibar.stringValue = "existing"
        let text = "some new text"

        omnibar.display(content: .selection(text: text))

        XCTAssertEqual(omnibar.stringValue, text)
    }

    func testDisplayContent_Prefix_ChangesStringValue() {

        let omnibar = Omnibar()
        omnibar.stringValue = "existing"
        let text = "replacement text"

        omnibar.display(content: .prefix(text: text))

        XCTAssertEqual(omnibar.stringValue, text)
    }

    func testDisplayContent_Suggestion_ChangesStringValue() {

        let omnibar = Omnibar()
        omnibar.stringValue = "existing"
        let text = "first part"
        let appendix = ", and the rest"

        omnibar.display(content: .suggestion(text: text, appendix: appendix))

        XCTAssertEqual(omnibar.stringValue, "first part, and the rest")
    }
}
