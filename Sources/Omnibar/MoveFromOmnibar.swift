//  Copyright © 2025 Christian Tietze. All rights reserved. Distributed under the MIT License.

/// Movement event forwarded by the ``Omnibar``.
///
/// Holding shift to expand the selection while using a movement key (e.g. the keyboard's arrow keys) will set ``isExpandingSelection`` to `true`. The default movement does not expand the selection and is intended to merely change a single selected item.
public struct MovementEvent: Equatable, Sendable {
    public enum Movement: Equatable, Sendable {
        /// Move the selection one item towards the start of the list.
        case up

        /// Move the selection one item towards the end of the list.
        case down

        /// Move the selection to the first item of the list.
        case top

        /// Move the selection to the last item of the list.
        case bottom
    }

    public let movement: Movement
    public let isExpandingSelection: Bool

    public init(
        movement: Movement,
        expandingSelection isExpandingSelection: Bool = false
    ) {
        self.movement = movement
        self.isExpandingSelection = isExpandingSelection
    }
}

/// Action handler used by ``Omnibar`` to forward movement events to change the selection in search results.
@MainActor
public struct MoveFromOmnibar {
    let handler: @MainActor (_ event: MovementEvent) -> Void

    public init(handler: @escaping @MainActor (_ event: MovementEvent) -> Void) {
        self.handler = handler
    }

    public func move(_ movement: MovementEvent) {
        handler(movement)
    }

    @inlinable @inline(__always)
    public func callAsFunction(event: MovementEvent) {
        move(event)
    }

    @inlinable @inline(__always)
    public func callAsFunction(
        movement: MovementEvent.Movement,
        expandingSelection isExpandingSelection: Bool = false
    ) {
        move(
            MovementEvent(
                movement: movement,
                expandingSelection: isExpandingSelection
            )
        )
    }
}
