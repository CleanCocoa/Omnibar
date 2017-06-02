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

    public func createRxOmnibarDelegateProxy() -> RxOmnibarDelegateProxy {
        return RxOmnibarDelegateProxy(parentObject: self)
    }
}

public enum MoveSelection {
    case previous, next
}

public struct RxOmnibarContentChange {
    public let contentChange: OmnibarContentChange
    public let method: ChangeMethod

    public init(contentChange: OmnibarContentChange, method: ChangeMethod) {

        self.contentChange = contentChange
        self.method = method
    }
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

    public var contentChange: ControlEvent<RxOmnibarContentChange> {

        let source = RxOmnibarDelegateProxy
            .proxyForObject(base)
            .contentChangePublishSubject
        return ControlEvent(events: source)
    }
}

public class RxOmnibarDelegateProxy
    : DelegateProxy
    , DelegateProxyType
    , OmnibarDelegate {

    public override class func createProxyForObject(_ object: AnyObject) -> AnyObject {

        let omnibar: Omnibar = castOrFatalError(object)
        return omnibar.createRxOmnibarDelegateProxy()
    }

    public class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {

        let omnibar: Omnibar = castOrFatalError(object)
        omnibar.delegate = castOptionalOrFatalError(delegate)
    }

    public class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {

        let omnibar: Omnibar = castOrFatalError(object)
        return omnibar.delegate
    }

    fileprivate var _contentChange: PublishSubject<RxOmnibarContentChange>?

    // Used instead of lazy var to not initialize the object in deinit.
    var contentChangePublishSubject: PublishSubject<RxOmnibarContentChange> {

        if let subject = _contentChange {
            return subject
        }

        let subject = PublishSubject<RxOmnibarContentChange>()
        _contentChange = subject
        return subject
    }

    deinit {

        _contentChange?.on(.completed)
    }

    public func omnibar(_ omnibar: Omnibar, contentChange: OmnibarContentChange, method: ChangeMethod) {

        _contentChange?.on(.next(RxOmnibarContentChange(contentChange: contentChange, method: method)))

        if let forwardingTo = self._forwardToDelegate as? OmnibarDelegate {
            forwardingTo.omnibar(omnibar, contentChange: contentChange, method: method)
        }
    }
}
