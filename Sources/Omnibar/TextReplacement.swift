//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import struct Foundation.NSRange

struct TextReplacement: Equatable {
    let text: String
    let selectedRange: NSRange
}

extension TextReplacement {
    init(omnibarContent: OmnibarContent) {
        self.text = omnibarContent.string
        self.selectedRange = omnibarContent.selectionRange
    }
}
