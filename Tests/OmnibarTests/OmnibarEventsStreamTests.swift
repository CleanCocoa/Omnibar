//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit
import Testing
@testable import Omnibar

@MainActor
@Suite("Omnibar: events stream")
struct OmnibarEventsStreamTests {

    // MARK: - Each event kind reaches a stream

    @Test("a content change reaches a stream")
    func contentChangeReachesStream() async {
        let omnibar = Omnibar()
        var stream = omnibar.events().makeAsyncIterator()

        omnibar.display(content: .prefix(text: "aard"))

        #expect(await stream.next() == .contentChange(.replacement(text: "aard"), method: .programmaticReplacement))
    }

    @Test("a commit reaches a stream")
    func commitReachesStream() async {
        let omnibar = Omnibar()
        omnibar.stringValue = "aardvark"
        var stream = omnibar.events().makeAsyncIterator()

        omnibar.commit()

        #expect(await stream.next() == .commit(text: "aardvark"))
    }

    @Test("a cancellation reaches a stream")
    func cancelReachesStream() async {
        let omnibar = Omnibar()
        var stream = omnibar.events().makeAsyncIterator()

        omnibar.focusAndClearText()

        #expect(await stream.next() == .cancel)
    }

    @Test("a movement reaches a stream")
    func movementReachesStream() async {
        let omnibar = Omnibar()
        var stream = omnibar.events().makeAsyncIterator()

        let didHandle = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveDown(_:)))

        #expect(didHandle)
        #expect(await stream.next() == .movement(MovementEvent(movement: .down)))
    }

    // MARK: - Fan-out and late registration

    @Test("every stream receives every event, including one created after an earlier event")
    func fanOutAndLateStreamRegistration() async {
        let omnibar = Omnibar()
        var first = omnibar.events().makeAsyncIterator()

        omnibar.commit()
        #expect(await first.next() == .commit(text: ""))

        var second = omnibar.events().makeAsyncIterator()
        omnibar.commit()

        #expect(await first.next() == .commit(text: ""))
        #expect(await second.next() == .commit(text: ""))
    }

    // MARK: - Ordering

    @Test("a stream sees events in the same order closure observers do")
    func streamOrderMatchesObserverOrder() async {
        let omnibar = Omnibar()
        var handlerLog: [OmnibarEvent] = []
        omnibar.observe { handlerLog.append($0) }
        var stream = omnibar.events().makeAsyncIterator()

        omnibar.display(content: .prefix(text: "kar"))
        _ = omnibar.doOmnibarCommand(commandSelector: #selector(NSResponder.moveDown(_:)))
        omnibar.commit()

        var streamLog: [OmnibarEvent] = []
        streamLog.append(await stream.next()!)
        streamLog.append(await stream.next()!)
        streamLog.append(await stream.next()!)

        #expect(streamLog == handlerLog)
    }

    @Test("legacy slots fire before closure observers; the stream sink also receives the event")
    func legacyThenObserversThenStream() async {
        let omnibar = Omnibar()
        var log: [String] = []
        let delegate = LoggingDelegate { kind in log.append("legacy:\(kind)") }
        omnibar.omnibarContentChangeDelegate = delegate
        omnibar.observe { _ in log.append("observer") }
        var stream = omnibar.events().makeAsyncIterator()

        omnibar.display(content: .prefix(text: "x"))

        #expect(log == ["legacy:change", "observer"])
        #expect(await stream.next() == .contentChange(.replacement(text: "x"), method: .programmaticReplacement))
    }

    // MARK: - Live registration mid-dispatch

    @Test("a stream created while an event is being dispatched still receives that event")
    func streamCreatedDuringDispatchReceivesInFlightEvent() async {
        let omnibar = Omnibar()
        var lateStream: AsyncStream<OmnibarEvent>.AsyncIterator!
        var lateStreamRegistered = false
        omnibar.observe { _ in
            guard !lateStreamRegistered else { return }
            lateStreamRegistered = true
            lateStream = omnibar.events().makeAsyncIterator()
        }

        omnibar.commit()

        #expect(await lateStream.next() == .commit(text: ""))
    }

    // MARK: - Buffering policy

    @Test("a non-default bufferingPolicy is honoured")
    func bufferingPolicyIsHonoured() async {
        let omnibar = Omnibar()
        var stream = omnibar.events(bufferingPolicy: .bufferingNewest(1)).makeAsyncIterator()

        omnibar.stringValue = "one"
        omnibar.commit()
        omnibar.stringValue = "two"
        omnibar.commit()
        omnibar.stringValue = "three"
        omnibar.commit()

        #expect(await stream.next() == .commit(text: "three"))
    }

    // MARK: - Terminated-sink pruning

    @Test("a sink whose consuming task was cancelled is pruned on the next emit", .timeLimit(.minutes(1)))
    func terminatedSinkIsPrunedOnNextEmit() async {
        let omnibar = Omnibar()
        let stream = omnibar.events()

        let task = Task {
            for await _ in stream { }
        }
        task.cancel()
        await task.value

        #expect(omnibar.sinks.withLock { $0.count } == 1)

        omnibar.commit()

        #expect(omnibar.sinks.withLock { $0.count } == 0)
    }

    // MARK: - deinit

    @Test("deinit ends every outstanding stream", .timeLimit(.minutes(1)))
    func deinitEndsStreams() async {
        weak var weakOmnibar: Omnibar?
        var stream: AsyncStream<OmnibarEvent>.AsyncIterator!

        autoreleasepool {
            let omnibar = Omnibar()
            weakOmnibar = omnibar
            stream = omnibar.events().makeAsyncIterator()
        }

        #expect(weakOmnibar == nil)
        #expect(await stream.next() == nil)
    }
}

private final class LoggingDelegate: OmnibarContentChangeDelegate {
    let onEvent: (String) -> Void

    init(onEvent: @escaping (String) -> Void) {
        self.onEvent = onEvent
    }

    func omnibar(_ omnibar: Omnibar, didChangeContent contentChange: OmnibarContentChange, method: ChangeMethod) {
        onEvent("change")
    }

    func omnibar(_ omnibar: Omnibar, commit text: String) {
        onEvent("commit")
    }

    func omnibarDidCancelOperation(_ omnibar: Omnibar) {
        onEvent("cancel")
    }
}
