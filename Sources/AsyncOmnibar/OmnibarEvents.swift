//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar

/// Publishes an ``Omnibar``'s user interactions as ``OmnibarEvent`` streams.
///
/// Observes `omnibar` from `init` until ``finish()`` without claiming its delegate or action slots, so any number of observers and a delegate can watch the same Omnibar at once:
///
///     self.events = OmnibarEvents(omnibar: omnibar)
///     self.observation = Task { [events] in
///         for await event in events.makeStream() {
///             switch event { /* ... */ }
///         }
///     }
///
/// Streams end when this object is released or when ``finish()`` is called. Deallocating the Omnibar does not end them, and a task consuming one holds this object alive, so stop the loop by cancelling that task or by calling ``finish()``.
///
/// There is no async counterpart for *displaying* content: call `Omnibar.display(content:)` directly from the main actor.
@MainActor
public final class OmnibarEvents {

    private var observation: Omnibar.Observation?

    private var continuations: [AsyncStream<OmnibarEvent>.Continuation] = []
    private var isFinished = false

    public init(omnibar: Omnibar) {
        self.observation = omnibar.observe { [weak self] event in
            self?.emit(event)
        }
    }

    /// Ends the streams of an observer released without ``finish()``, which would otherwise suspend their consumers forever.
    deinit {
        for continuation in continuations {
            continuation.finish()
        }
    }

    /// Returns a new stream that observes every event from this point on.
    ///
    /// Streams are independent: each one receives all events, so several parts of the app can observe the same Omnibar. Events are buffered without bound rather than dropped, because discarding a ``OmnibarEvent/commit(text:)`` would silently lose a search the user confirmed.
    ///
    /// Returns an already-finished stream once ``finish()`` has been called.
    public func makeStream() -> AsyncStream<OmnibarEvent> {
        let (stream, continuation) = AsyncStream.makeStream(
            of: OmnibarEvent.self,
            bufferingPolicy: .unbounded)

        guard !isFinished else {
            continuation.finish()
            return stream
        }

        continuations.append(continuation)

        return stream
    }

    /// Ends all streams and stops observing the Omnibar.
    ///
    /// Idempotent, and latching: streams handed out afterwards are already finished. Independent of every other observer, so teardown order does not matter.
    public func finish() {
        guard !isFinished else { return }
        isFinished = true

        for continuation in continuations {
            continuation.finish()
        }
        continuations.removeAll()

        observation?.cancel()
        observation = nil
    }

    /// Drops the streams whose consumer has gone away, which `yield` reports as it delivers.
    private func emit(_ event: OmnibarEvent) {
        continuations.removeAll { continuation in
            if case .terminated = continuation.yield(event) { true } else { false }
        }
    }
}
