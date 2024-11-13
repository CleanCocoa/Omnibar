//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import RxSwift
import RxCocoa
import RxTest
import Omnibar
import RxOmnibar

class Omnibar_RxTests: XCTestCase, RxTestHelpers {

    func testTextCompletesOnDealloc() {
        let createView: () -> Omnibar = { Omnibar(frame: CGRect(x: 0, y: 0, width: 1, height: 1)) }
        ensurePropertyDeallocated(createView, "a") { (view: Omnibar) in view.rx.text }
    }
}


// MARK: - Display Content

extension Omnibar_RxTests {

    func testContentSink_Empty() {

        let omnibar = Omnibar()
        omnibar.stringValue = "something"

        _ = Observable.just(OmnibarContent.empty).bind(to: omnibar.rx.content)

        XCTAssertEqual(omnibar.stringValue, "")
    }

    func testContentSink_Prefix() {

        let omnibar = Omnibar()

        _ = Observable.just(OmnibarContent.prefix(text: "hello there")).bind(to: omnibar.rx.content)

        XCTAssertEqual(omnibar.stringValue, "hello there")
    }

    func testContentSink_Selection() {

        let omnibar = Omnibar()

        _ = Observable.just(OmnibarContent.selection(text: "como estas")).bind(to: omnibar.rx.content)

        XCTAssertEqual(omnibar.stringValue, "como estas")
    }

    func testContentSink_Suggestion() {

        let omnibar = Omnibar()

        _ = Observable.just(OmnibarContent.suggestion(text: "foo", appendix: " bar")).bind(to: omnibar.rx.content)

        XCTAssertEqual(omnibar.stringValue, "foo bar")
    }
}


// MARK: - Selection

extension Omnibar_RxTests {

    func testControlCommand_MoveSelection_PublishesEvent() {

        let scheduler = TestScheduler(initialClock: 0)
        let omnibar = Omnibar()

        scheduler.scheduleAt(300) { _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveUp(_:))) }
        scheduler.scheduleAt(400) { _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveUp(_:))) }
        scheduler.scheduleAt(500) { _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveDown(_:))) }
        // Other selectors should be ignored
        scheduler.scheduleAt(600) { _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.insertNewline(_:))) }

        let result = scheduler.start { omnibar.rx.moveSelection.asObservable() }

        let expected: [Recorded<Event<RxOmnibar.MoveSelection>>] = [
            Recorded.next(300, .previous(expandingSelection: false)),
            Recorded.next(400, .previous(expandingSelection: false)),
            Recorded.next(500, .next(expandingSelection: false))
        ]
        XCTAssertEqual(result.events, expected)
    }

    func testControlCommand_MoveSelectionWithDelegates_PublishesEventAndCallsDelegate() {

        let scheduler = TestScheduler(initialClock: 0)
        let omnibar = Omnibar()
        let double = SelectionDelegateDouble()
        omnibar.omnibarDelegate = double

        scheduler.scheduleAt(500) { _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveUp(_:))) }
        scheduler.scheduleAt(600) { _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveDown(_:))) }
        scheduler.scheduleAt(700) { _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.insertNewline(_:))) }
        scheduler.scheduleAt(800) { _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveUp(_:))) }


        let result = scheduler.start { omnibar.rx.moveSelection.asObservable() }

        let expected: [Recorded<Event<RxOmnibar.MoveSelection>>] = [
            Recorded.next(500, .previous(expandingSelection: false)),
            Recorded.next(600, .next(expandingSelection: false)),
            Recorded.next(800, .previous(expandingSelection: false))
        ]
        XCTAssertEqual(result.events, expected)
        XCTAssertEqual(double.didSelectNext, 1)
        XCTAssertEqual(double.didSelectPrevious, 2)
    }

}

extension RxOmnibar.MoveSelection: @retroactive Equatable {
    public static func ==(lhs: RxOmnibar.MoveSelection, rhs: RxOmnibar.MoveSelection) -> Bool {
        switch (lhs, rhs) {
        case let (.first(lExpandSelection), .first(rExpandSelection)):
            return lExpandSelection == rExpandSelection
        case let (.previous(lExpandSelection), .previous(rExpandSelection)):
            return lExpandSelection == rExpandSelection
        case let (.next(lExpandSelection), .next(rExpandSelection)):
            return lExpandSelection == rExpandSelection
        case let (.last(lExpandSelection), .last(rExpandSelection)):
            return lExpandSelection == rExpandSelection
        default: return false
        }
    }
}

final class SelectionDelegateDouble: OmnibarDelegate {

    public func omnibar(_ omnibar: Omnibar, commit text: String) {
        // no op
    }

    func omnibar(_ omnibar: Omnibar, contentChange: OmnibarContentChange, method: ChangeMethod) {
        // no op
    }

    func omnibarDidCancelOperation(_ omnibar: Omnibar) {
        // no op
    }

    var didSelectPrevious: Int = 0
    func omnibarSelectPrevious(_ omnibar: Omnibar) {
        didSelectPrevious += 1
    }

    var didSelectNext: Int = 0
    func omnibarSelectNext(_ omnibar: Omnibar) {
        didSelectNext += 1
    }
}


// MARK: - Omnibar Content Changes

extension RxOmnibarContentChange: @retroactive Equatable {}

public func ==(lhs: RxOmnibarContentChange, rhs: RxOmnibarContentChange) -> Bool {

    return lhs.contentChange == rhs.contentChange
        && lhs.method == rhs.method
}

extension Omnibar_RxTests {

    func testContentChange_PublishesEvent() {

        let scheduler = TestScheduler(initialClock: 0)
        let omnibar = Omnibar()

        let firstChange = TextFieldTextChange(oldText: "original", patch: "", range: NSRange(location: 0, length: 12), method: .insertion)
        scheduler.scheduleAt(300) { omnibar.processTextChange(firstChange) }
        let secondChange = TextFieldTextChange(oldText: "whatever", patch: "Yggdrasil", range: NSRange(location: 33, length: 0), method: .insertion)
        scheduler.scheduleAt(400) { omnibar.processTextChange(secondChange) }

        let result = scheduler.start { omnibar.rx.contentChange.asObservable() }

        XCTAssertEqual(result.events, [
            Recorded.next(300, RxOmnibarContentChange(contentChange: OmnibarContentChange(base: .empty, change: firstChange), method: .insertion, requestNumber: 1)),
            Recorded.next(400, RxOmnibarContentChange(contentChange: OmnibarContentChange(base: .empty, change: secondChange), method: .insertion, requestNumber: 2))
            ])
    }
}


// MARK: - Commits

extension Omnibar_RxTests {

    func testCommits_PublishesEvent() {

        let scheduler = TestScheduler(initialClock: 0)
        let omnibar = Omnibar()

        scheduler.scheduleAt(400) {
            omnibar.stringValue = "shnabubula"
            omnibar.commit()
        }
        scheduler.scheduleAt(600) {
            omnibar.stringValue = "overclocked"
            omnibar.commit()
        }

        let result = scheduler.start { omnibar.rx.commits.asObservable() }

        XCTAssertEqual(result.events, [
            Recorded.next(400, "shnabubula"),
            Recorded.next(600, "overclocked")
            ])
    }
}
