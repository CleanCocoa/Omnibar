//  Copyright © 2025 Christian Tietze. All rights reserved. Distributed under the MIT License.

/// Movement event forwarded by the ``Omnibar``.
///
/// Holding shift to expand the selection while using a movement key (e.g. the keyboard's arrow keys) will set ``isExpandingSelection`` to `true`. The default movement does not expand the selection and is intended to merely change a single selected item.
public struct MovementEvent: Equatable {
    public enum Movement: Equatable {
        /// - Next: Called when the down arrow key is pressed from inside the Omnibar.
        /// - Last: Called when the down arrow key is pressed from inside the Omnibar while the Command or Alt modifier key is held.

        /// Called when the up arrow key is pressed from inside the Omnibar.
        case up
        case down

        /// Called when the up arrow key is pressed from inside the Omnibar while the Command or Alt modifier key is held.
        case top
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
