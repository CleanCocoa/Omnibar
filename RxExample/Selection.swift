//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

struct Selection {

    let word: String
}

import Omnibar

extension Selection: OmnibarContentConvertible {

    var omnibarContent: OmnibarContent {
        return .selection(text: word)
    }
}
