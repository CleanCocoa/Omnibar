//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

@IBDesignable
open class Omnibar: NSView {

    let textField: NSTextField = {
        let textField = NSTextField()
        textField.usesSingleLineMode = true
        return textField
    }()

    public convenience init() {
        self.init(frame: NSRect.zero)
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        layoutSubviews()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        layoutSubviews()
    }

    private func layoutSubviews() {

        textField.frame = self.bounds
        textField.autoresizingMask = [.viewWidthSizable]
        textField.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(textField)

        self.autoresizingMask = [.viewWidthSizable]
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}

extension Omnibar: DisplaysOmnibarContent {

    public func display(content: OmnibarContent) {

        self.stringValue = content.string
    }
}


// MARK: Text Field Adapter

extension Omnibar {

    open override var intrinsicContentSize: NSSize {
        return textField.intrinsicContentSize
    }

    @IBInspectable open var alignment: NSTextAlignment {
        get { return textField.alignment }
        set { textField.alignment = newValue }
    }

    @IBInspectable open var font: NSFont? {
        get { return textField.font }
        set { textField.font = newValue }
    }

    @IBInspectable open var placeholder: String? {
        get { return textField.placeholderString }
        set { textField.placeholderString = newValue }
    }

    open var stringValue: String {
        get { return textField.stringValue }
        set { textField.stringValue = newValue }
    }
}
