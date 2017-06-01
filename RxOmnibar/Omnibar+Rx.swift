//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar
import RxSwift
import RxCocoa

public extension Reactive where Base: Omnibar {

    public var text: ControlProperty<String> {
        return base._textField.rx.text.orEmpty
    }
}
