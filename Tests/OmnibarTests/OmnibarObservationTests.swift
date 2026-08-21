//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit
import Testing
@testable import Omnibar

@MainActor
@Suite("Omnibar: observation")
struct OmnibarObservationTests {

    // MARK: - Each event kind reaches an observer

    @Test("a content change reaches an observer")
    func contentChangeReachesObserver() {
        let omnibar = Omnibar()
        var received: [OmnibarEvent] = []
        let observation = omnibar.observe { received.append($0) }

        omnibar.display(content: .prefix(text: "aard"))

        #expect(received == [.contentChange(.replacement(text: "aard"), method: .programmaticReplacement)])
        withExtendedLifetime(observation) { }
    }

    @Test("a commit reaches an observer")
    func commitReachesObserver() {
        let omnibar = Omnibar()
        omnibar.stringValue = "aardvark"
        var received: [OmnibarEvent] = []
        let observation = omnibar.observe { received.append($0) }

        omnibar.commit()

        #expect(received == [.commit(text: "aardvark")])
        withExtendedLifetime(observation) { }
    }

    @Test("a cancellation reaches an observer")
    func cancelReachesObserver() {
        let omnibar = Omnibar()
        var received: [OmnibarEvent] = []
        let observation = omnibar.observe { received.append($0) }

        omnibar.focusAndClearText()

        #expect(received == [.cancel])
        withExtendedLifetime(observation) { }
    }

    @Test("a movement reaches an observer")
    func movementReachesObserver() {
        let omnibar = Omnibar()
        var received: [OmnibarEvent] = []
        let observation = omnibar.observe { received.append($0) }

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveDown(_:)))

        #expect(didHandle)
        #expect(received == [.movement(MovementEvent(movement: .down))])
        withExtendedLifetime(observation) { }
    }

    // MARK: - Fan-out

    @Test("every observer receives every event")
    func fanOutToAllObservers() {
        let omnibar = Omnibar()
        var first: [OmnibarEvent] = []
        var second: [OmnibarEvent] = []
        let firstObservation = omnibar.observe { first.append($0) }
        let secondObservation = omnibar.observe { second.append($0) }

        omnibar.display(content: .selection(text: "karate"))

        let expected = [OmnibarEvent.contentChange(.replacement(text: "karate"), method: .programmaticReplacement)]
        #expect(first == expected)
        #expect(second == expected)
        withExtendedLifetime((firstObservation, secondObservation)) { }
    }

    // MARK: - Registration order

    @Test("observers are notified in registration order")
    func observersNotifiedInRegistrationOrder() {
        let omnibar = Omnibar()
        var order: [String] = []
        let firstObservation = omnibar.observe { _ in order.append("first") }
        let secondObservation = omnibar.observe { _ in order.append("second") }

        omnibar.commit()

        #expect(order == ["first", "second"])
        withExtendedLifetime((firstObservation, secondObservation)) { }
    }

    // MARK: - Ownership

    @Test("a handler that captures the Omnibar weakly lets it deallocate")
    func handlerCapturingOmnibarWeaklyLetsItDeallocate() {
        weak var weakRef: Omnibar?

        autoreleasepool {
            let omnibar = Omnibar()
            weakRef = omnibar
            _ = omnibar.observe { [weak omnibar] _ in _ = omnibar?.stringValue }
        }

        #expect(weakRef == nil)
    }

    // MARK: - Cancellation

    @Test("cancel() stops delivery")
    func cancelStopsDelivery() {
        let omnibar = Omnibar()
        var received: [OmnibarEvent] = []
        let observation = omnibar.observe { received.append($0) }

        observation.cancel()
        omnibar.commit()

        #expect(received.isEmpty)
    }

    @Test("cancel() is a no-op the second time")
    func cancelTwiceIsNoOp() {
        let omnibar = Omnibar()
        var received: [OmnibarEvent] = []
        let observation = omnibar.observe { received.append($0) }

        observation.cancel()
        observation.cancel()
        omnibar.commit()

        #expect(received.isEmpty)
    }

    @Test("cancel() after the Omnibar is gone does not crash")
    func cancelAfterOmnibarGoneDoesNotCrash() {
        var omnibar: Omnibar? = Omnibar()
        weak let weakOmnibar = omnibar
        let observation = omnibar!.observe { _ in }

        omnibar = nil

        #expect(weakOmnibar == nil)
        observation.cancel()
    }

    // MARK: - Cancel on release

    @Test("a dropped observation is pruned at the next dispatch and never fires")
    func droppedObservationIsPrunedAndNeverFires() {
        let omnibar = Omnibar()
        var received: [OmnibarEvent] = []

        _ = omnibar.observe { received.append($0) }

        omnibar.commit()

        #expect(received.isEmpty)
    }

    @Test("a held observation fires")
    func heldObservationFires() {
        let omnibar = Omnibar()
        var received: [OmnibarEvent] = []

        let observation = omnibar.observe { received.append($0) }

        omnibar.commit()

        #expect(received == [.commit(text: "")])
        withExtendedLifetime(observation) { }
    }

    @Test("five dropped observations leave no live registrations")
    func fiveDroppedObservationsLeaveNoLiveRegistrations() {
        let omnibar = Omnibar()
        var receivedCount = 0

        for _ in 0..<5 {
            _ = omnibar.observe { _ in receivedCount += 1 }
        }

        omnibar.commit()

        #expect(receivedCount == 0)
        #expect(omnibar.observers.isEmpty)
    }

    // MARK: - Order-independent teardown

    @Test("cancelling the first observation leaves the second one working")
    func cancelFirstLeavesSecondWorking() {
        let omnibar = Omnibar()
        var firstLog: [OmnibarEvent] = []
        var secondLog: [OmnibarEvent] = []
        let first = omnibar.observe { firstLog.append($0) }
        let second = omnibar.observe { secondLog.append($0) }

        first.cancel()
        omnibar.commit()

        #expect(firstLog.isEmpty)
        #expect(secondLog == [.commit(text: "")])
        withExtendedLifetime(second) { }
    }

    @Test("cancelling the second observation leaves the first one working")
    func cancelSecondLeavesFirstWorking() {
        let omnibar = Omnibar()
        var firstLog: [OmnibarEvent] = []
        var secondLog: [OmnibarEvent] = []
        let first = omnibar.observe { firstLog.append($0) }
        let second = omnibar.observe { secondLog.append($0) }

        second.cancel()
        omnibar.commit()

        #expect(secondLog.isEmpty)
        #expect(firstLog == [.commit(text: "")])
        withExtendedLifetime(first) { }
    }

    // MARK: - Snapshot semantics mid-dispatch

    @Test("an observer registered during dispatch skips the in-flight event but is registered for the next one")
    func observerRegisteredDuringDispatchSkipsInFlightEventButRegisters() {
        let omnibar = Omnibar()
        var lateLog: [OmnibarEvent] = []
        var lateObserverRegistered = false
        var lateObservation: Omnibar.Observation?
        let earlyObservation = omnibar.observe { _ in
            guard !lateObserverRegistered else { return }
            lateObserverRegistered = true
            lateObservation = omnibar.observe { lateLog.append($0) }
        }

        omnibar.commit()
        #expect(lateLog.isEmpty)

        omnibar.commit()
        #expect(lateLog == [.commit(text: "")])
        withExtendedLifetime((earlyObservation, lateObservation)) { }
    }

    @Test("an observer cancelled during dispatch still receives the in-flight event")
    func observerCancelledDuringDispatchReceivesInFlightEvent() {
        let omnibar = Omnibar()
        var secondLog: [OmnibarEvent] = []
        let secondObservationBox = ObservationBox()
        let firstObservation = omnibar.observe { _ in
            secondObservationBox.value?.cancel()
        }
        secondObservationBox.value = omnibar.observe { secondLog.append($0) }

        omnibar.commit()

        #expect(secondLog == [.commit(text: "")])
        withExtendedLifetime(firstObservation) { }
    }

    @Test("an observer registered by another observer's handler receives only the handler-caused echo, not the in-flight event")
    func observerRegisteredDuringDispatchViaHandlerReceivesOnlyEcho() {
        let omnibar = Omnibar()
        var bLog: [OmnibarEvent] = []
        var bObservation: Omnibar.Observation?
        var registered = false
        let aObservation = omnibar.observe { _ in
            guard !registered else { return }
            registered = true
            bObservation = omnibar.observe { bLog.append($0) }
            omnibar.display(content: .prefix(text: "echo"))
        }

        omnibar.display(content: .prefix(text: "original"))

        let echo = OmnibarEvent.contentChange(.replacement(text: "echo"), method: .programmaticReplacement)
        #expect(bLog == [echo])
        withExtendedLifetime((aObservation, bObservation)) { }
    }

    // MARK: - Re-entrancy

    @Test("a handler-triggered display() is serialized after the event that caused it, for every observer")
    func reentrantDisplayIsSerializedForEveryObserver() {
        let omnibar = Omnibar()
        var aLog: [OmnibarEvent] = []
        var bLog: [OmnibarEvent] = []

        let aObservation = omnibar.observe { event in
            aLog.append(event)
            if aLog.count == 1 {
                omnibar.display(content: .prefix(text: "echo"))
            }
        }
        let bObservation = omnibar.observe { event in
            bLog.append(event)
        }

        omnibar.display(content: .prefix(text: "original"))

        let original = OmnibarEvent.contentChange(.replacement(text: "original"), method: .programmaticReplacement)
        let echo = OmnibarEvent.contentChange(.replacement(text: "echo"), method: .programmaticReplacement)

        #expect(bLog == [original, echo])
        #expect(aLog == [original, echo])
        withExtendedLifetime((aObservation, bObservation)) { }
    }

    @Test("display(content:) called from inside a handler still mutates stringValue synchronously")
    func displayFromHandlerMutatesSynchronously() {
        let omnibar = Omnibar()
        var valueDuringEcho: String?

        let observation = omnibar.observe { event in
            guard case .contentChange(.replacement(text: "original"), method: .programmaticReplacement) = event else { return }
            omnibar.display(content: .prefix(text: "echo"))
            valueDuringEcho = omnibar.stringValue
        }

        omnibar.display(content: .prefix(text: "original"))

        #expect(valueDuringEcho == "echo")
        withExtendedLifetime(observation) { }
    }

    // MARK: - Event kind ordering

    @Test("processTextChange(_:) on a continuation emits the nested display() before its own content change")
    func continuationEmitsNestedDisplayFirst() {
        let omnibar = Omnibar()
        let baseText = "same base"
        let appendixText = "continued here"
        omnibar.display(content: .suggestion(text: baseText, appendix: appendixText))

        var log: [OmnibarEvent] = []
        let observation = omnibar.observe { log.append($0) }

        let appendixRange = NSRange(
            location: (baseText as NSString).length,
            length: (appendixText as NSString).length)
        let textChange = TextFieldTextChange(
            oldText: baseText,
            patch: "c",
            range: appendixRange,
            method: .appending)

        omnibar.processTextChange(textChange)

        #expect(log == [
            .contentChange(.replacement(text: "same basecontinued here"), method: .programmaticReplacement),
            .contentChange(.continuation(text: "same basec", remainingAppendix: "ontinued here"), method: .appending),
        ])
        withExtendedLifetime(observation) { }
    }

    // MARK: - Esc ordering

    @Test("Esc emits the deletion content change before cancel")
    func escOrderingEmitsDeletionThenCancel() {
        let (omnibar, window) = makeFocusedOmnibarInWindow()
        var log: [OmnibarEvent] = []
        let observation = omnibar.observe { log.append($0) }

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.cancelOperation(_:)))

        #expect(didHandle)
        #expect(log == [
            .contentChange(.replacement(text: ""), method: .deletion),
            .cancel,
        ])
        withExtendedLifetime((window, observation)) { }
    }

    @Test("Esc on a field with text emits the deletion content change before cancel, via fieldEditor.delete(_:)")
    func escOrderingWithTextEmitsDeletionThenCancel() {
        let (omnibar, window) = makeFocusedOmnibarInWindow(text: "aardvark")

        let fieldEditor = window.fieldEditor(true, for: omnibar)
        #expect(fieldEditor?.string == "aardvark")

        var log: [OmnibarEvent] = []
        let observation = omnibar.observe { log.append($0) }

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.cancelOperation(_:)))

        #expect(didHandle)
        #expect(log == [
            .contentChange(.replacement(text: ""), method: .deletion),
            .cancel,
        ])
        withExtendedLifetime((window, observation)) { }
    }

    @Test("Esc with alwaysFireWhenClearingText disabled only cancels an already-empty Omnibar")
    func escWithAlwaysFireWhenClearingTextFalseOnlyCancels() {
        let (omnibar, window) = makeFocusedOmnibarInWindow()
        omnibar.alwaysFireWhenClearingText = false
        var log: [OmnibarEvent] = []
        let observation = omnibar.observe { log.append($0) }

        _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.cancelOperation(_:)))

        #expect(log == [.cancel])
        withExtendedLifetime((window, observation)) { }
    }

    @Test("Esc does nothing when isResettable is false")
    func escWithIsResettableFalseDoesNothing() {
        let (omnibar, window) = makeFocusedOmnibarInWindow()
        omnibar.isResettable = false
        var log: [OmnibarEvent] = []
        let observation = omnibar.observe { log.append($0) }

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.cancelOperation(_:)))

        #expect(!didHandle)
        #expect(log.isEmpty)
        withExtendedLifetime((window, observation)) { }
    }
}

/// Puts a focused ``Omnibar`` in a real window so `window?.fieldEditor(true, for:)` resolves.
@MainActor
private func makeFocusedOmnibarInWindow(text: String = "") -> (omnibar: Omnibar, window: NSWindow) {
    let omnibar = Omnibar()
    omnibar.stringValue = text
    let window = NSWindow(
        contentRect: NSRect(x: 0, y: 0, width: 200, height: 40),
        styleMask: [.titled],
        backing: .buffered,
        defer: false)
    window.contentView?.addSubview(omnibar)
    window.makeFirstResponder(omnibar)
    return (omnibar, window)
}

@MainActor
private final class ObservationBox {
    var value: Omnibar.Observation?
}
