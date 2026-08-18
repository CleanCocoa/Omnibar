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
/// **Call ``finish()`` when the observer's owner goes away.** A task consuming a stream keeps the observer alive, and the observer only ends its streams once it is released, so waiting for deallocation to stop the loop waits forever.
///
/// There is no async counterpart for *displaying* content: call `Omnibar.display(content:)` directly from the main actor.
@MainActor
public final class OmnibarEvents {

    private weak var omnibar: Omnibar?
    private weak var displacedDelegate: OmnibarContentChangeDelegate?
    private let displacedMovement: MoveFromOmnibar?

    private var continuations: [Int: AsyncStream<OmnibarEvent>.Continuation] = [:]
    private var nextID = 0
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

        let id = nextID
        nextID += 1
        continuation.onTermination = { [weak self] _ in
            // Termination is reported from whatever context ended the stream, so the bookkeeping has to hop back here. Until it lands, `emit(_:)` may still yield to this continuation, which a finished stream ignores.
            Task { @MainActor in
                self?.continuations[id] = nil
            }
        }
        continuations[id] = continuation

        return stream
    }

    /// Ends all streams and returns the Omnibar's delegate and action slots to whatever held them before.
    ///
    /// Idempotent, and latching: streams handed out afterwards are already finished.
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
        for continuation in continuations.values {
            continuation.finish()
        }
        continuations.removeAll()
    }

    private func emit(_ event: OmnibarEvent) {
        for continuation in continuations.values {
            continuation.yield(event)
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
