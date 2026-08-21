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
