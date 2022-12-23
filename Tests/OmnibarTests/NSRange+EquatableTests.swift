//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import Omnibar

class NSRange_EquatableTests: XCTestCase {

    func testEquatability() {

        XCTAssertEqual(NSRange(), NSRange())
        XCTAssertEqual(NSRange(), NSRange(location: 0, length: 0))
        XCTAssertEqual(NSRange(location: 4, length: 3), NSRange(location: 4, length: 3))
        XCTAssertNotEqual(NSRange(), NSRange(location: 1, length: 0))
        XCTAssertNotEqual(NSRange(), NSRange(location: 0, length: 1))
        XCTAssertNotEqual(NSRange(location: 99, length: -17), NSRange(location: 12, length: 753))
    }
}
