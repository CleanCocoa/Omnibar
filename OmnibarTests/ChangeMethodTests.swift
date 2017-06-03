//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import Omnibar

class ChangeMethodTests: XCTestCase {

    func testInit() {

        XCTAssert(ChangeMethod(original: "foo", replacement: "x", affectedRange: NSRange(location: 0, length: 0)) == .insertion)
        XCTAssert(ChangeMethod(original: "foo", replacement: "x", affectedRange: NSRange(location: 1, length: 0)) == .insertion)
        XCTAssert(ChangeMethod(original: "foo", replacement: "x", affectedRange: NSRange(location: 2, length: 0)) == .insertion)

        XCTAssert(ChangeMethod(original: "foo", replacement: "x", affectedRange: NSRange(location: 3, length: 0)) == .appending)

        // Empty insertion comes before deletion
        XCTAssert(ChangeMethod(original: "foo", replacement: "", affectedRange: NSRange(location: 0, length: 0)) == .insertion)
        XCTAssert(ChangeMethod(original: "foo", replacement: "", affectedRange: NSRange(location: 3, length: 0)) == .appending)

        XCTAssert(ChangeMethod(original: "foo", replacement: "", affectedRange: NSRange(location: 0, length: 1)) == .deletion)
        XCTAssert(ChangeMethod(original: "foo", replacement: "", affectedRange: NSRange(location: 1, length: 2)) == .deletion)
    }
}
