//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Omnibar
import Testing

@Suite("NSRange: Equatable")
struct NSRangeEquatableTests {

    @Test("equal locations and lengths compare equal")
    func equality() {
        #expect(NSRange() == NSRange())
        #expect(NSRange() == NSRange(location: 0, length: 0))
        #expect(NSRange(location: 4, length: 3) == NSRange(location: 4, length: 3))
    }

    @Test("a difference in either component compares unequal")
    func inequality() {
        #expect(NSRange() != NSRange(location: 1, length: 0))
        #expect(NSRange() != NSRange(location: 0, length: 1))
        #expect(NSRange(location: 99, length: -17) != NSRange(location: 12, length: 753))
    }
}
