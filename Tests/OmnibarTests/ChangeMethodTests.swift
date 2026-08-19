//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Testing
@testable import Omnibar

@Suite("ChangeMethod")
struct ChangeMethodTests {

    @Test("classifies a patch inside the text as insertion")
    func insertionInsideText() {
        #expect(ChangeMethod(original: "foo", replacement: "x", affectedRange: NSRange(location: 0, length: 0)) == .insertion)
        #expect(ChangeMethod(original: "foo", replacement: "x", affectedRange: NSRange(location: 1, length: 0)) == .insertion)
        #expect(ChangeMethod(original: "foo", replacement: "x", affectedRange: NSRange(location: 2, length: 0)) == .insertion)
    }

    @Test("classifies a patch past the end as appending")
    func appendingPastEnd() {
        #expect(ChangeMethod(original: "foo", replacement: "x", affectedRange: NSRange(location: 3, length: 0)) == .appending)
    }

    @Test("classifies an empty patch of nothing by position, not by emptiness")
    func emptyInsertionComesBeforeDeletion() {
        #expect(ChangeMethod(original: "foo", replacement: "", affectedRange: NSRange(location: 0, length: 0)) == .insertion)
        #expect(ChangeMethod(original: "foo", replacement: "", affectedRange: NSRange(location: 3, length: 0)) == .appending)
    }

    @Test("classifies an empty patch over a range as deletion")
    func deletionOverRange() {
        #expect(ChangeMethod(original: "foo", replacement: "", affectedRange: NSRange(location: 0, length: 1)) == .deletion)
        #expect(ChangeMethod(original: "foo", replacement: "", affectedRange: NSRange(location: 1, length: 2)) == .deletion)
    }
}
