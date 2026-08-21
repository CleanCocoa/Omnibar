//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit
import AsyncOmnibar
import Omnibar
import Testing

@MainActor
@Suite("OmnibarEvents")
struct OmnibarEventsTests {

    @Test("forwards programmatic content changes")
    func forwardsProgrammaticContentChange() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        var stream = events.makeStream().makeAsyncIterator()

        omnibar.display(content: .prefix(text: "aard"))

        #expect(
            await stream.next()
                == .contentChange(.replacement(text: "aard"), method: .programmaticReplacement))
    }

    @Test("forwards commits")
    func forwardsCommit() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        var stream = events.makeStream().makeAsyncIterator()

        omnibar.stringValue = "aardvark"
        omnibar.commit()

        #expect(await stream.next() == .commit(text: "aardvark"))
    }

    @Test("forwards cancellation")
    func forwardsCancellation() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        var stream = events.makeStream().makeAsyncIterator()

        omnibar.focusAndClearText()

        #expect(await stream.next() == .cancel)
    }

    @Test("forwards movement commands")
    func forwardsMovement() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        var stream = events.makeStream().makeAsyncIterator()

        _ = omnibar.textView(
            NSTextView(),
            doCommandBy: #selector(NSResponder.moveDownAndModifySelection(_:)))

        #expect(
            await stream.next()
                == .movement(MovementEvent(movement: .down, expandingSelection: true)))
    }

    @Test("delivers every event to every stream")
    func multicastsToAllStreams() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        var first = events.makeStream().makeAsyncIterator()
        var second = events.makeStream().makeAsyncIterator()

        omnibar.display(content: .selection(text: "karate"))

        let expected = OmnibarEvent.contentChange(
            .replacement(text: "karate"),
            method: .programmaticReplacement)
        #expect(await first.next() == expected)
        #expect(await second.next() == expected)
    }

    @Test("preserves the order the Omnibar produced events in")
    func preservesEventOrder() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        var stream = events.makeStream().makeAsyncIterator()

        omnibar.display(content: .prefix(text: "kar"))
        _ = omnibar.textView(NSTextView(), doCommandBy: #selector(NSResponder.moveDown(_:)))
        omnibar.commit()

        #expect(
            await stream.next()
                == .contentChange(.replacement(text: "kar"), method: .programmaticReplacement))
        #expect(await stream.next() == .movement(MovementEvent(movement: .down)))
        #expect(await stream.next() == .commit(text: "kar"))
    }

    @Test("finish() ends the streams")
    func finishEndsStreams() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        var stream = events.makeStream().makeAsyncIterator()

        events.finish()

        #expect(await stream.next() == nil)
    }

    @Test("streams handed out after finish() are already finished")
    func makeStreamAfterFinishIsEmpty() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        events.finish()

        var stream = events.makeStream().makeAsyncIterator()

        #expect(await stream.next() == nil)
    }

    @Test("two observers on one Omnibar both receive every event", .timeLimit(.minutes(1)))
    func observersDoNotDisplaceEachOther() async {
        let omnibar = Omnibar()
        let first = OmnibarEvents(omnibar: omnibar)
        let second = OmnibarEvents(omnibar: omnibar)
        var firstStream = first.makeStream().makeAsyncIterator()
        var secondStream = second.makeStream().makeAsyncIterator()

        omnibar.commit()

        #expect(await firstStream.next() == .commit(text: ""))
        #expect(await secondStream.next() == .commit(text: ""))
    }

    @Test("tearing observers down out of order leaves the survivors working", .timeLimit(.minutes(1)))
    func teardownOrderDoesNotMatter() async {
        let omnibar = Omnibar()
        let first = OmnibarEvents(omnibar: omnibar)
        let second = OmnibarEvents(omnibar: omnibar)
        var secondStream = second.makeStream().makeAsyncIterator()

        first.finish()
        first.finish()
        omnibar.commit()

        #expect(await secondStream.next() == .commit(text: ""))
    }

    @Test("releasing the observer ends the streams")
    func releasingObserverEndsStreams() async {
        let omnibar = Omnibar()
        var events: OmnibarEvents? = OmnibarEvents(omnibar: omnibar)
        var stream = events!.makeStream().makeAsyncIterator()

        events = nil

        #expect(await stream.next() == nil)
    }
}
