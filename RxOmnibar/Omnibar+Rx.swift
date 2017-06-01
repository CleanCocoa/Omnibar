//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar
import RxSwift
import RxCocoa

public extension Reactive where Base: Omnibar {

    public var text: ControlProperty<String> {
        return base._textField.rx.text.orEmpty
    }
}

// MARK: - Selection

extension Omnibar {

    public func createRxSelectionDelegateProxy() -> RxOmnibarSelectionDelegateProxy {
        return RxOmnibarSelectionDelegateProxy(parentObject: self)
    }
}

public enum MoveSelection {
    case previous, next
}

public extension Reactive where Base: Omnibar {

    public var selectionDelegate: RxOmnibarSelectionDelegateProxy {
        return RxOmnibarSelectionDelegateProxy.proxyForObject(base)
    }

    public var moveSelection: Observable<MoveSelection> {

        let delegate = selectionDelegate
        let selectNext = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectNext(_:)))
            .map { _ in return MoveSelection.next }
        let selectPrevious = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectPrevious(_:)))
            .map { _ in return MoveSelection.previous }
        return Observable.of(selectNext, selectPrevious).merge()
    }
}

public class RxOmnibarSelectionDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , OmnibarSelectionDelegate {

    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {

        let omnibar: Omnibar = castOrFatalError(object)
        return omnibar.createRxSelectionDelegateProxy()
    }

    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let omnibar: Omnibar = castOrFatalError(object)
        omnibar.selectionDelegate = castOptionalOrFatalError(delegate)
    }

    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let omnibar: Omnibar = castOrFatalError(object)
        return omnibar.selectionDelegate
    }
}
