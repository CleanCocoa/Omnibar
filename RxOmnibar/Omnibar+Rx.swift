//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar
import RxSwift
import RxCocoa

public struct OmnibarContentResponse {
    public let omnibarContent: OmnibarContent
    public let requestNumber: Int

    public init(omnibarContent: OmnibarContent, requestNumber: Int) {

        self.omnibarContent = omnibarContent
        self.requestNumber = requestNumber
    }
}

public extension Reactive where Base: Omnibar {

    /// Reactive wrapper for the text property, based on `stringValue`.
    public var text: ControlProperty<String> {
        return base._textField.rx.text.orEmpty
    }

    /// Content sink to change the text and selection of the Omnibar.
    public var content: UIBindingObserver<Omnibar, OmnibarContent> {
        return UIBindingObserver(UIElement: base) { (omnibar: Omnibar, content: OmnibarContent) in
            omnibar.display(content: content)
        }
    }

    public var contentResponseSink: AnyObserver<OmnibarContentResponse> {

        let requestNumbers = self.contentChange.asDriver()
            .map { $0.requestNumber }
        let publish = PublishSubject<OmnibarContentResponse>()

        let subscription = publish.asDriver(onErrorDriveWith: .empty())
            .withLatestFrom(requestNumbers) { response, number in (response, number) }
            .filter { response, latestRequestNumber in response.requestNumber >= latestRequestNumber }
            .map { response, _ in response.omnibarContent }
            .drive(content)

        return AnyObserver { [subscription] event in

            guard case .next(let response) = event else { return }

            publish.onNext(response)
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

    /// Control event for pressing the up or down arrow keys inside the Omnibar.
    public var moveSelection: ControlEvent<MoveSelection> {

        let delegate = self.delegate
        let selectNext = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectNext(_:)))
            .map { _ in return MoveSelection.next }
        let selectPrevious = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectPrevious(_:)))
            .map { _ in return MoveSelection.previous }
        let combined = Observable.of(selectNext, selectPrevious).merge()
        return ControlEvent(events: combined)
    }
}


// MARK: Content Change

public struct RxOmnibarContentChange {

    public let contentChange: OmnibarContentChange
    public let method: ChangeMethod
    public let requestNumber: Int

    public init(
        contentChange: OmnibarContentChange,
        method: ChangeMethod,
        requestNumber: Int) {

        self.contentChange = contentChange
        self.method = method
        self.requestNumber = requestNumber
    }
}

public extension Reactive where Base: Omnibar {

    /// Control event for user-generated changes to the omnibar.
    public var contentChange: ControlEvent<RxOmnibarContentChange> {

        let source = RxOmnibarDelegateProxy
            .proxyForObject(base)
            .contentChangePublishSubject
        return ControlEvent(events: source)
    }
}


// MARK: Text Commits

public extension Reactive where Base: Omnibar {

    /// Sequence of committed text, e.g. through hitting the Enter key.
    public var commits: ControlEvent<String> {

        let source = RxOmnibarDelegateProxy
            .proxyForObject(base)
            .commitsPublishSubject
        return ControlEvent(events: source)
    }
}
