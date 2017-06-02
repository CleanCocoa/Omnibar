//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar
import RxSwift
import RxCocoa

public extension Reactive where Base: Omnibar {

    public var text: ControlProperty<String> {
        return base._textField.rx.text.orEmpty
    }

    public var content: UIBindingObserver<Omnibar, OmnibarContent> {
        return UIBindingObserver(UIElement: base) { (omnibar: Omnibar, content: OmnibarContent) in
            omnibar.display(content: content)
        }
    }
}


// MARK: - Rx-ified Delegate

extension Omnibar {

    public func createRxOmnibarDelegateProxy() -> RxOmnibarDelegateProxy {
        return RxOmnibarDelegateProxy(parentObject: self)
    }
}


// MARK: Selection

public enum MoveSelection {
    case previous, next
}

public extension Reactive where Base: Omnibar {

    public var delegate: RxOmnibarDelegateProxy {
        return RxOmnibarDelegateProxy.proxyForObject(base)
    }

    public var moveSelection: Observable<MoveSelection> {

        let delegate = self.delegate
        let selectNext = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectNext(_:)))
            .map { _ in return MoveSelection.next }
        let selectPrevious = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectPrevious(_:)))
            .map { _ in return MoveSelection.previous }
        return Observable.of(selectNext, selectPrevious).merge()
    }
}


// MARK: Content Change

public struct RxOmnibarContentChange {

    public let contentChange: OmnibarContentChange
    public let method: ChangeMethod

    public init(contentChange: OmnibarContentChange, method: ChangeMethod) {

        self.contentChange = contentChange
        self.method = method
    }
}

public extension Reactive where Base: Omnibar {

    public var contentChange: ControlEvent<RxOmnibarContentChange> {

        let source = RxOmnibarDelegateProxy
            .proxyForObject(base)
            .contentChangePublishSubject
        return ControlEvent(events: source)
    }
}
