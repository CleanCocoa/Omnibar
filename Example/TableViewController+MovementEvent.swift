//  Copyright © 2025 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar

extension TableViewController {
    func move(_ event: MovementEvent) {
        switch event.movement {
        case .top:
            selectFirst()
        case .bottom:
            selectLast()
        case .up:
            selectPrevious()
        case .down:
            selectNext()
        }
    }
}
