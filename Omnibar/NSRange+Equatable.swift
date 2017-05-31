//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

extension NSRange: Equatable { }

public func ==(lhs: NSRange, rhs: NSRange) -> Bool {

    return lhs.location == rhs.location
        && lhs.length == rhs.length
}
