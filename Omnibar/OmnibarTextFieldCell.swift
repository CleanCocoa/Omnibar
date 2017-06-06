//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class OmnibarTextFieldCell: NSTextFieldCell {

    var insets: Omnibar.Insets?

    public override func drawingRect(forBounds rect: NSRect) -> NSRect {

        guard let insets = self.insets else {
            return super.drawingRect(forBounds: rect)
        }

        var drawingRect = super.drawingRect(forBounds: rect)
        drawingRect.size.width -= insets.width
        drawingRect.origin.x += insets.left
        return drawingRect
    }
}
