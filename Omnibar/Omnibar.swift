//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

public class Omnibar: NSTextField {

}

extension Omnibar: DisplaysOmnibarContent {

    public func display(content: OmnibarContent) {

        self.stringValue = content.string
    }
}
