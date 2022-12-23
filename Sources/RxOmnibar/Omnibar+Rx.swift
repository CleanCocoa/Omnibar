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

extension Reactive where Base: Omnibar {

    /// Content sink to change the text and selection of the Omnibar.
    public var content: Binder<OmnibarContent> {
        return Binder(base) { (omnibar: Omnibar, content: OmnibarContent) in
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

            _ = subscription // keep alive
        }
    }
}


// MARK: - Rx-ified Delegate

// MARK: Selection

public enum MoveSelection {
    case first(expandingSelection: Bool)
    case previous(expandingSelection: Bool)
    case next(expandingSelection: Bool)
    case last(expandingSelection: Bool)
}

extension Reactive where Base: Omnibar {

    public var omnibarDelegate: RxOmnibarDelegateProxy {
        return RxOmnibarDelegateProxy.proxy(for: base)
    }

    /// Control event for pressing the up or down arrow keys inside the Omnibar.
    public var moveSelection: ControlEvent<MoveSelection> {

        let delegate = self.omnibarDelegate

        let selectFirst = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectFirst(_:)))
            .map { _ in return MoveSelection.first(expandingSelection: false) }
        let selectPrevious = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectPrevious(_:)))
            .map { _ in return MoveSelection.previous(expandingSelection: false) }
        let selectNext = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectNext(_:)))
            .map { _ in return MoveSelection.next(expandingSelection: false) }
        let selectLast = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarSelectLast(_:)))
            .map { _ in return MoveSelection.last(expandingSelection: false) }

        let expandToFirst = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarExpandSelectionToFirst(_:)))
            .map { _ in return MoveSelection.first(expandingSelection: true) }
        let expandToPrevious = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarExpandSelectionToPrevious(_:)))
            .map { _ in return MoveSelection.previous(expandingSelection: true) }
        let expandToNext = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarExpandSelectionToNext(_:)))
            .map { _ in return MoveSelection.next(expandingSelection: true) }
        let expandToLast = delegate
            .methodInvoked(#selector(OmnibarSelectionDelegate.omnibarExpandSelectionToLast(_:)))
            .map { _ in return MoveSelection.last(expandingSelection: true) }

        let combined = Observable
            .of(selectFirst,
                selectNext,
                selectPrevious,
                selectLast,

                expandToFirst,
                expandToPrevious,
                expandToNext,
                expandToLast)
            .merge()
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

extension Reactive where Base: Omnibar {

    /// Control event for user-generated changes to the omnibar.
    public var contentChange: ControlEvent<RxOmnibarContentChange> {

        let source = omnibarDelegate.contentChangePublishSubject
        return ControlEvent(events: source)
    }

    /// Sequence of committed text, e.g. through hitting the Enter key.
    public var commits: ControlEvent<String> {

        let source = omnibarDelegate.commitsPublishSubject
        return ControlEvent(events: source)
    }

    /// Cancel operations in the Omnibar, e.g. by hitting ESC.
    public var cancelOperations: ControlEvent<Void> {

        let source = omnibarDelegate.cancelPublishSubject
        return ControlEvent(events: source)
    }
}
