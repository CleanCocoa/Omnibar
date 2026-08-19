//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

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

    @Test("forwards movement from the action slot it claimed")
    func forwardsMovement() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        var stream = events.makeStream().makeAsyncIterator()

        omnibar.moveFromOmnibar?(movement: .down, expandingSelection: true)

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
        omnibar.moveFromOmnibar?(movement: .down)
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

    @Test("finish() releases the Omnibar's delegate and action slots")
    func finishReleasesOmnibar() {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)

        events.finish()

        #expect(omnibar.omnibarContentChangeDelegate == nil)
        #expect(omnibar.moveFromOmnibar == nil)
    }

    @Test("finish() puts back the delegate it displaced")
    func finishRestoresDisplacedDelegate() {
        let omnibar = Omnibar()
        let original = RecordingDelegate()
        omnibar.omnibarContentChangeDelegate = original
        let events = OmnibarEvents(omnibar: omnibar)

        events.finish()
        omnibar.commit()

        #expect(omnibar.omnibarContentChangeDelegate === original)
        #expect(original.commits == [""])
    }

    @Test("finish() puts back the movement handler it displaced")
    func finishRestoresDisplacedMovement() {
        let omnibar = Omnibar()
        let original = MovementRecorder()
        omnibar.moveFromOmnibar = MoveFromOmnibar { original.events.append($0) }
        let events = OmnibarEvents(omnibar: omnibar)

        events.finish()
        omnibar.moveFromOmnibar?(movement: .up)

        #expect(original.events == [MovementEvent(movement: .up)])
    }

    @Test("streams handed out after finish() are already finished")
    func makeStreamAfterFinishIsEmpty() async {
        let omnibar = Omnibar()
        let events = OmnibarEvents(omnibar: omnibar)
        events.finish()

        var stream = events.makeStream().makeAsyncIterator()

        #expect(await stream.next() == nil)
    }

    @Test("finish() does not reclaim slots a later observer took over")
    func finishLeavesLaterObserverAlone() {
        let omnibar = Omnibar()
        let first = OmnibarEvents(omnibar: omnibar)
        let second = OmnibarEvents(omnibar: omnibar)

        first.finish()
        first.finish()

        #expect(omnibar.omnibarContentChangeDelegate === second)
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

private final class RecordingDelegate: OmnibarContentChangeDelegate {
    var commits: [String] = []

    func omnibar(_ omnibar: Omnibar, didChangeContent contentChange: OmnibarContentChange, method: ChangeMethod) {}
    func omnibar(_ omnibar: Omnibar, commit text: String) { commits.append(text) }
    func omnibarDidCancelOperation(_ omnibar: Omnibar) {}
}

private final class MovementRecorder {
    var events: [MovementEvent] = []
}
