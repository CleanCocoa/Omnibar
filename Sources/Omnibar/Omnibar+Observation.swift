//  Copyright © 2026 Christian Tietze. All rights reserved. Distributed under the MIT License.

extension Omnibar {

    /// The Omnibar holds `token` weakly so a released observation is pruned at the next dispatch.
    struct ObserverEntry {
        weak var token: Observation?
        let handler: @MainActor (OmnibarEvent) -> Void
    }

    /// Stops delivery when cancelled or released.
    @MainActor
    public final class Observation {
        private weak var omnibar: Omnibar?

        init(omnibar: Omnibar) {
            self.omnibar = omnibar
        }

        /// Stops the handler from receiving further events. Safe to call more than once and after the ``Omnibar`` is gone.
        public func cancel() {
            omnibar?.removeObserver(self)
            omnibar = nil
        }
    }

    /// Registers `handler` for every event, in registration order.
    ///
    /// Delivery stops when the returned observation is cancelled or released, so the caller must hold it. Capture the Omnibar weakly in `handler`.
    public func observe(_ handler: @escaping @MainActor (OmnibarEvent) -> Void) -> Observation {
        let observation = Observation(omnibar: self)
        observers.append(ObserverEntry(token: observation, handler: handler))
        return observation
    }

    func removeObserver(_ observation: Observation) {
        observers.removeAll { $0.token === observation }
    }

    /// Returns a stream of every ``OmnibarEvent`` from this point on.
    ///
    /// Ends when the consuming task is cancelled or the ``Omnibar`` deallocates.
    public func events(
        bufferingPolicy: AsyncStream<OmnibarEvent>.Continuation.BufferingPolicy = .unbounded
    ) -> AsyncStream<OmnibarEvent> {
        let (stream, continuation) = AsyncStream.makeStream(of: OmnibarEvent.self, bufferingPolicy: bufferingPolicy)
        let id = nextSinkID
        nextSinkID += 1
        sinks[id] = continuation
        return stream
    }

    func emit(_ event: OmnibarEvent) {
        pendingEvents.append(event)

        guard !isEmitting else { return }
        isEmitting = true
        defer { isEmitting = false }

        while !pendingEvents.isEmpty {
            let next = pendingEvents.removeFirst()

            observers.removeAll { $0.token == nil }
            let observerSnapshot = observers
            let sinkSnapshot = sinks

            for observer in observerSnapshot { observer.handler(next) }

            for (id, continuation) in sinkSnapshot {
                if case .terminated = continuation.yield(next) {
                    sinks.removeValue(forKey: id)
                }
            }
        }
    }
}
