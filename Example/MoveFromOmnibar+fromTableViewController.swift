//  Copyright © 2025 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar

extension MoveFromOmnibar {
    init(wrapping tableViewController: TableViewController) {
        self.init { [tableViewController] event in
            switch event.movement {
            case .top:
                tableViewController.selectFirst()
            case .bottom:
                tableViewController.selectLast()
            case .up:
                tableViewController.selectPrevious()
            case .down:
                tableViewController.selectNext()
            }
        }
    }
}
