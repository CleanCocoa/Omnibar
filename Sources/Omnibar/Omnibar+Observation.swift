//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

extension Omnibar {

    /// Token returned by ``Omnibar/observe(_:)`` to stop receiving events.
    @MainActor
    public final class Observation {
        private weak var omnibar: Omnibar?
        private let id: Int

        init(omnibar: Omnibar, id: Int) {
            self.omnibar = omnibar
            self.id = id
        }

        /// Stops the handler from receiving further events. Safe to call more than once and after the ``Omnibar`` is gone.
        public func cancel() {
            omnibar?.removeObserver(id)
            omnibar = nil
        }
    }

    /// Registers `handler` to receive every ``OmnibarEvent``.
    ///
    /// The legacy ``Omnibar/omnibarContentChangeDelegate`` and ``Omnibar/moveFromOmnibar`` are notified where the event arises, then observers in registration order. An observer registered while an event is being dispatched does not receive that event; one cancelled mid-dispatch still receives it. Discarding the returned ``Observation`` keeps the handler observing for the ``Omnibar``'s lifetime.
    ///
    /// The Omnibar retains `handler` until the observation is cancelled; capture the Omnibar weakly inside it.
    @discardableResult
    public func observe(_ handler: @escaping @MainActor (OmnibarEvent) -> Void) -> Observation {
        let id = nextObserverID
        nextObserverID += 1
        observers.append((id: id, handler: handler))
        return Observation(omnibar: self, id: id)
    }

    func removeObserver(_ id: Int) {
        observers.removeAll { $0.id == id }
    }

    /// Returns a new stream of every ``OmnibarEvent`` from this point on.
    ///
    /// A stream created while an event is being dispatched still receives that event, unlike ``observe(_:)``. A consumer stops receiving events by cancelling its consuming `Task`; the stream also ends when the ``Omnibar`` deallocates.
    public func events(
        bufferingPolicy: AsyncStream<OmnibarEvent>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<OmnibarEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: OmnibarEvent.self, bufferingPolicy: bufferingPolicy)
        let id = nextSinkID
        nextSinkID += 1
        sinks.withLock { $0[id] = continuation }
        return stream
    }

    func emit(_ event: OmnibarEvent) {
        pendingEvents.append(event)

        // The legacy slots are notified where the event arises, so a delegate that re-enters display(content:) is called back inside its own callback as it was before observers existed.
        guard !isEmitting else {
            notifyLegacySlots(event)
            return
        }
        isEmitting = true
        defer { isEmitting = false }
        notifyLegacySlots(event)

        while !pendingEvents.isEmpty {
            let next = pendingEvents.removeFirst()
            for observer in observers { observer.handler(next) }
            sinks.withLock { open in
                open = open.filter { _, continuation in
                    if case .terminated = continuation.yield(next) { false } else { true }
                }
            }
        }
    }

    private func notifyLegacySlots(_ event: OmnibarEvent) {
        switch event {
        case let .contentChange(change, method: method):
            omnibarContentChangeDelegate?.omnibar(self, didChangeContent: change, method: method)
        case let .commit(text: text):
            omnibarContentChangeDelegate?.omnibar(self, commit: text)
        case .cancel:
            omnibarContentChangeDelegate?.omnibarDidCancelOperation(self)
        case let .movement(event):
            moveFromOmnibar?(event: event)
        }
    }
}
