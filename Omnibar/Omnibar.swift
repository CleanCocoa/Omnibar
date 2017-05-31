//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSTextField: EditableText { }

@IBDesignable @objc
open class Omnibar: NSView {

    @IBOutlet public weak var delegate: OmnibarDelegate?

    lazy var textField: NSTextField = {
        let textField = NSTextField()
        textField.usesSingleLineMode = true
        textField.delegate = self
        return textField
    }()

    /// Testing seam.
    var editableText: EditableText { return textField }

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

extension Omnibar: NSTextFieldDelegate {

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {

        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)):
            delegate?.omnibarSelectNext(self)
            return true

        case #selector(NSResponder.moveUp(_:)):
            delegate?.omnibarSelectPrevious(self)
            return true

        default: return false
        }
    }
}

extension Omnibar: DisplaysOmnibarContent {

    public func display(content: OmnibarContent) {

        editableText.replace(replacement: TextReplacement(omnibarContent: content))
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

    open override var acceptsFirstResponder: Bool {
        return textField.acceptsFirstResponder
    }

    open override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }

    open override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
}
