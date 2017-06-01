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

// MARK: - Selection

extension Omnibar_RxTests {

    func testControlCommand_MoveSelection_PublishesEvent() {

        let scheduler = TestScheduler(initialClock: 0)
        let omnibar = Omnibar()

        let irrelevantControl = NSControl()
        let irrelevantTextView = NSTextView()

        scheduler.scheduleAt(300) { _ = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.moveUp(_:))) }
        scheduler.scheduleAt(400) { _ = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.moveUp(_:))) }
        scheduler.scheduleAt(500) { _ = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.moveDown(_:))) }
        // Other selectors should be ignored
        scheduler.scheduleAt(600) { _ = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.insertNewline(_:))) }

        let result = scheduler.start { omnibar.rx.moveSelection }

        XCTAssertEqual(result.events, [
            next(300, .previous),
            next(400, .previous),
            next(500, .next)
            ])
    }

    func testControlCommand_MoveSelectionWithDelegates_PublishesEventAndCallsDelegate() {

        let scheduler = TestScheduler(initialClock: 0)
        let omnibar = Omnibar()
        let double = SelectionDelegateDouble()
        omnibar.selectionDelegate = double

        let irrelevantControl = NSControl()
        let irrelevantTextView = NSTextView()

        scheduler.scheduleAt(500) { _ = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.moveUp(_:))) }
        scheduler.scheduleAt(600) { _ = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.moveDown(_:))) }
        scheduler.scheduleAt(700) { _ = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.insertNewline(_:))) }
        scheduler.scheduleAt(800) { _ = omnibar.control(irrelevantControl, textView: irrelevantTextView, doCommandBy: #selector(NSResponder.moveUp(_:))) }


        let result = scheduler.start { omnibar.rx.moveSelection }

        XCTAssertEqual(result.events, [
            next(500, .previous),
            next(600, .next),
            next(800, .previous)
            ])
        XCTAssertEqual(double.didSelectNext, 1)
        XCTAssertEqual(double.didSelectPrevious, 2)
    }

}

final class SelectionDelegateDouble: OmnibarSelectionDelegate {
    var didSelectPrevious: Int = 0
    func omnibarSelectPrevious(_ omnibar: Omnibar) {
        didSelectPrevious += 1
    }

    var didSelectNext: Int = 0
    func omnibarSelectNext(_ omnibar: Omnibar) {
        didSelectNext += 1
    }
}
