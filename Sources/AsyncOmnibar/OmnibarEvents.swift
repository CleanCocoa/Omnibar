//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar

/// Publishes an ``Omnibar``'s user interactions as ``OmnibarEvent`` streams.
///
/// Occupies both the `omnibarContentChangeDelegate` and the `moveFromOmnibar` slot of `omnibar` from `init` until ``finish()``, putting back whatever occupied them before. The Omnibar holds its delegate weakly, so the observer has to be stored by the caller:
///
///     self.events = OmnibarEvents(omnibar: omnibar)
///     self.observation = Task { [events] in
///         for await event in events.makeStream() {
///             switch event { /* ... */ }
///         }
///     }
///
/// **Call ``finish()`` when the observer's owner goes away.** A task consuming a stream keeps the observer alive, and the observer only ends its streams once it is released, so waiting for deallocation to stop the loop waits forever. ``finish()`` is main actor-isolated, so an owner tearing down in `deinit` needs an `isolated deinit`.
///
/// There is no async counterpart for *displaying* content: call `Omnibar.display(content:)` directly from the main actor.
@MainActor
public final class OmnibarEvents {

    private weak var omnibar: Omnibar?
    private weak var displacedDelegate: OmnibarContentChangeDelegate?
    private let displacedMovement: MoveFromOmnibar?

    private var continuations: [AsyncStream<OmnibarEvent>.Continuation] = []
    private var isFinished = false

    public init(omnibar: Omnibar) {
        self.omnibar = omnibar
        self.displacedDelegate = omnibar.omnibarContentChangeDelegate
        self.displacedMovement = omnibar.moveFromOmnibar

        omnibar.omnibarContentChangeDelegate = self
        omnibar.moveFromOmnibar = MoveFromOmnibar { [weak self] event in
            self?.emit(.movement(event))
        }
    }

    /// Backstop for observers released without ``finish()``.
    ///
    /// `AsyncStream` keeps its consumers suspended forever when the last reference to its continuation is released, so dropping the observer without ending its streams would hang every `for await` loop over it.
    ///
    /// This cannot hand the Omnibar's slots back: the Omnibar's weak reference to this object reads as `nil` here, which is indistinguishable from another observer having claimed the slot in the meantime. An Omnibar torn down this way keeps an inert movement handler installed and does not see its previous delegate again.
    isolated deinit {
        finishStreams()
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

    /// Ends all streams and returns the Omnibar's delegate and action slots to whatever held them before.
    ///
    /// Idempotent, and latching: streams handed out afterwards are already finished.
    ///
    /// Whether the slots still belong to this observer is decided by the delegate alone, since `MoveFromOmnibar` has no identity to compare. Installing a movement handler over this observer's while leaving the delegate in place therefore loses that handler here.
    public func finish() {
        guard !isFinished else { return }
        isFinished = true

        finishStreams()

        // Only reclaim slots this observer still occupies; anything installed later owns them now.
        guard let omnibar,
              omnibar.omnibarContentChangeDelegate === self
        else { return }
        omnibar.omnibarContentChangeDelegate = displacedDelegate
        omnibar.moveFromOmnibar = displacedMovement
    }

    private func finishStreams() {
        for continuation in continuations {
            continuation.finish()
        }
        continuations.removeAll()
    }

    /// Drops the streams whose consumer has gone away, which `yield` reports as it delivers.
    private func emit(_ event: OmnibarEvent) {
        continuations.removeAll { continuation in
            if case .terminated = continuation.yield(event) { true } else { false }
        }
    }
}

extension OmnibarEvents: OmnibarContentChangeDelegate {

    public func omnibar(
        _ omnibar: Omnibar,
        didChangeContent contentChange: OmnibarContentChange,
        method: ChangeMethod
    ) {
        emit(.contentChange(contentChange, method: method))
    }

    public func omnibar(
        _ omnibar: Omnibar,
        commit text: String
    ) {
        emit(.commit(text: text))
    }

    public func omnibarDidCancelOperation(_ omnibar: Omnibar) {
        emit(.cancel)
    }
}
