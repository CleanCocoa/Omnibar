//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSTextField: EditableText { }

@IBDesignable @objc
open class Omnibar: NSView {

    public weak var selectionDelegate: OmnibarSelectionDelegate?
    public weak var contentDelegate: OmnibarContentChangeDelegate?

    lazy var textField: OmnibarTextField = {
        let textField = OmnibarTextField()
        textField.usesSingleLineMode = true
        textField.delegate = self
        textField.textChangeDelegate = self
        return textField
    }()

    /// Testing seam.
    var editableText: EditableText { return textField }

    fileprivate var lastContent: OmnibarContent?

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


// MARK: - Input

extension Omnibar: DisplaysOmnibarContent {

    public func display(content: OmnibarContent) {

        editableText.replace(replacement: TextReplacement(omnibarContent: content))

        // Update cache
        lastContent = content
    }
}


// MARK: - Output

extension Omnibar: NSTextFieldDelegate, TextChangeDelegate {

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {

        switch commandSelector {
        case #selector(NSResponder.moveDown(_:)):
            selectionDelegate?.omnibarSelectNext?(self)
            return true

        case #selector(NSResponder.moveUp(_:)):
            selectionDelegate?.omnibarSelectPrevious?(self)
            return true

        default: return false
        }
    }

    internal func omnibarTextField(_ omnibarTextField: OmnibarTextField, willChange textChange: TextFieldTextChange) {

        let lastContent = self.lastContent ?? .empty

        contentDelegate?.omnibar(self, contentChanges: OmnibarContentChange(base: lastContent, change: textChange))
    }
}


// MARK: - Text Field Adapter

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
