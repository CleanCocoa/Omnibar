//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Omnibar

/// Publishes an ``Omnibar``'s user interactions as ``OmnibarEvent`` streams.
///
/// Occupies both the `omnibarContentChangeDelegate` and the `moveFromOmnibar` slot of `omnibar` for as long as it lives. The Omnibar holds its delegate weakly, so **the observer has to be stored by the caller**; letting it go out of scope ends every stream it vended:
///
///     self.events = OmnibarEvents(omnibar: omnibar)
///     for await event in self.events.makeStream() {
///         switch event { /* ... */ }
///     }
///
/// There is no async counterpart for *displaying* content: call `Omnibar.display(content:)` directly from the main actor.
@MainActor
public final class OmnibarEvents {

    private weak var omnibar: Omnibar?
    private var continuations: [Int: AsyncStream<OmnibarEvent>.Continuation] = [:]
    private var nextID = 0

    public init(omnibar: Omnibar) {
        self.omnibar = omnibar

        omnibar.omnibarContentChangeDelegate = self
        omnibar.moveFromOmnibar = MoveFromOmnibar { [weak self] event in
            self?.emit(.movement(event))
        }
    }

    /// Ends the streams that outlived the observer.
    ///
    /// `AsyncStream` keeps its consumers suspended forever when the last reference to its continuation is released, so dropping the observer without finishing them would hang every `for await` loop over it.
    ///
    /// Reclaiming the Omnibar's slots is left to ``finish()``: the Omnibar's weak reference to this object is already `nil` here, and the movement handler it still holds captures `self` weakly, so what remains installed is inert.
    isolated deinit {
        finishStreams()
    }

    /// Returns a new stream that observes every event from this point on.
    ///
    /// Streams are independent: each one receives all events, so several parts of the app can observe the same Omnibar. Events are buffered without bound rather than dropped, because discarding a ``OmnibarEvent/commit(text:)`` would silently lose a search the user confirmed.
    public func makeStream() -> AsyncStream<OmnibarEvent> {
        let id = nextID
        nextID += 1

        let (stream, continuation) = AsyncStream.makeStream(
            of: OmnibarEvent.self,
            bufferingPolicy: .unbounded)
        continuation.onTermination = { [weak self] _ in
            // Termination is reported from whatever context ended the stream, so the bookkeeping has to hop back here. Until it lands, `emit(_:)` may still yield to this continuation, which a finished stream ignores.
            Task { @MainActor in
                self?.continuations[id] = nil
            }
        }
        continuations[id] = continuation

        return stream
    }

    /// Ends all streams and gives up the Omnibar's delegate and action slots.
    ///
    /// Only needed to tear down early; releasing the observer has the same effect.
    public func finish() {
        finishStreams()

        guard let omnibar,
              omnibar.omnibarContentChangeDelegate === self
        else { return }
        omnibar.omnibarContentChangeDelegate = nil
        omnibar.moveFromOmnibar = nil
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
