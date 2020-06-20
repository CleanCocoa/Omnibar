//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar
import RxSwift
import RxCocoa

public class RxOmnibarDelegateProxy
    : DelegateProxy<Omnibar, OmnibarDelegate>
    , DelegateProxyType
    , OmnibarDelegate
{

    // MARK: - DelegateProxy Implementation

    public init(omnibar: Omnibar) {
        super.init(
            parentObject: omnibar,
            delegateProxy: RxOmnibarDelegateProxy.self)
    }

    public static func registerKnownImplementations() {

        self.register { RxOmnibarDelegateProxy(omnibar: $0) }
    }
    
    public static func currentDelegate(for object: Omnibar) -> OmnibarDelegate? {
        return object.omnibarDelegate
    }
    
    public static func setCurrentDelegate(_ delegate: OmnibarDelegate?, to object: Omnibar) {
        object.omnibarDelegate = delegate
    }

    // MARK: - OmnibarDelegate Implementation

    // Use the private/internal property dance instead of lazy var to not initialize the object in deinit.

    fileprivate var _contentChange: PublishSubject<RxOmnibarContentChange>?

    var contentChangePublishSubject: PublishSubject<RxOmnibarContentChange> {

        if let subject = _contentChange {
            return subject
        }

        let subject = PublishSubject<RxOmnibarContentChange>()
        _contentChange = subject
        return subject
    }

    fileprivate var _commits: PublishSubject<String>?

    var commitsPublishSubject: PublishSubject<String> {

        if let subject = _commits {
            return subject
        }

        let subject = PublishSubject<String>()
        _commits = subject
        return subject
    }

    fileprivate var _cancelOperations: PublishSubject<Void>?

    var cancelPublishSubject: PublishSubject<Void> {

        if let subject = _cancelOperations {
            return subject
        }

        let subject = PublishSubject<Void>()
        _cancelOperations = subject
        return subject
    }

    deinit {

        _contentChange?.on(.completed)
        _commits?.on(.completed)
        _cancelOperations?.on(.completed)
    }

    fileprivate var requestNumber: Int = 0

    public func omnibar(_ omnibar: Omnibar, contentChange: OmnibarContentChange, method: ChangeMethod) {

        requestNumber += 1

        _contentChange?.on(.next(RxOmnibarContentChange(
            contentChange: contentChange,
            method: method,
            requestNumber: self.requestNumber)))

        if let forwardingTo = self._forwardToDelegate as? OmnibarDelegate {
            forwardingTo.omnibar(omnibar, contentChange: contentChange, method: method)
        }
    }

    public func omnibar(_ omnibar: Omnibar, commit text: String) {

        _commits?.on(.next(text))

        if let forwardingTo = self._forwardToDelegate as? OmnibarDelegate {
            forwardingTo.omnibar(omnibar, commit: text)
        }
    }

    public func omnibarDidCancelOperation(_ omnibar: Omnibar) {

        _cancelOperations?.on(.next(()))

        if let forwardingTo = self._forwardToDelegate as? OmnibarDelegate {
            forwardingTo.omnibarDidCancelOperation(omnibar)
        }
    }
}
