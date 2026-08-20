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
    /// The legacy ``Omnibar/omnibarContentChangeDelegate`` and ``Omnibar/moveFromOmnibar`` are notified first, then observers in registration order. An observer registered while an event is being dispatched does not receive that event; one cancelled mid-dispatch still receives it. Discarding the returned ``Observation`` keeps the handler observing for the ``Omnibar``'s lifetime.
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

    func emit(_ event: OmnibarEvent) {
        pendingEvents.append(event)
        guard !isEmitting else { return }
        isEmitting = true
        defer { isEmitting = false }
        while !pendingEvents.isEmpty {
            let next = pendingEvents.removeFirst()
            notifyLegacySlots(next)
            let recipients = observers
            for observer in recipients { observer.handler(next) }
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
