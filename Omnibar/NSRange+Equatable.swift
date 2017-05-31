//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import struct Foundation.NSRange

extension NSRange: Equatable { }

public func ==(lhs: NSRange, rhs: NSRange) -> Bool {

    return lhs.location == rhs.location
        && lhs.length == rhs.length
}
