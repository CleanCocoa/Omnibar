//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSTextField: EditableText { }

/// Display model cache that forces us to consider the latest value once, only.
/// This way, resetting auto-completions will need to call
/// `Omnibar.display(content:)` again. The last suggestion is forgotten if it
/// is not carried on.
class PreviousContent {

    init() { }

    private var lastContent: OmnibarContent?

    func pushLatest(_ content: OmnibarContent) {
        lastContent = content
    }

    func popLatest() -> OmnibarContent? {
        let result = lastContent
        lastContent = nil
        return result
    }
}

@IBDesignable @objc
open class Omnibar: NSView {

    public weak var delegate: OmnibarDelegate?

    public lazy var _textField: OmnibarTextField = {
        let textField = OmnibarTextField()
        textField.usesSingleLineMode = true
        textField.delegate = self
        return textField
    }()

    /// Testing seam.
    var editableText: EditableText { return _textField }

    /// Display model cache.
    let previousContent = PreviousContent()

    /// Enable/disable resetting the contents with the Esc key. `True` by default.
    open var isResettable: Bool = true

    open var usesTabForNextResponder: Bool = true

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

        _textField.frame = self.bounds
        _textField.autoresizingMask = [.viewWidthSizable]
        _textField.translatesAutoresizingMaskIntoConstraints = true
        self.addSubview(_textField)

        self.autoresizingMask = [.viewWidthSizable]
        self.translatesAutoresizingMaskIntoConstraints = true
    }
}


// MARK: - Input

extension Omnibar: DisplaysOmnibarContent {

    public func display(content: OmnibarContent) {

        editableText.replace(replacement: TextReplacement(omnibarContent: content))

        // Update cache
        previousContent.pushLatest(content)
    }
}


// MARK: - Output

extension Omnibar: NSTextFieldDelegate {

    public func control(_ control: NSControl, textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {

        switch commandSelector {
        case #selector(NSResponder.cancelOperation(_:)):
            guard isResettable else { return false }

            self.focusAndClearText()
            return true

        case #selector(NSResponder.insertNewline(_:)),
             #selector(NSResponder.insertLineBreak(_:)),
             #selector(NSResponder.insertNewlineIgnoringFieldEditor(_:)):

            self.commit()
            return true

        case #selector(NSResponder.moveDown(_:)):
            delegate?.omnibarSelectNext?(self)
            return true

        case #selector(NSResponder.moveUp(_:)):
            delegate?.omnibarSelectPrevious?(self)
            return true

        default: return false
        }
    }

    open override func controlTextDidChange(_ obj: Notification) {

        guard let textField = obj.object as? OmnibarTextField
            else { fatalError("controlTextDidChange expected for OmnibarTextField") }

        guard let textChange = textField.popTextFieldChange()
            else { preconditionFailure("text change setting should precede notification") }

        processTextChange(textChange)
    }

    open func processTextChange(_ textChange: TextFieldTextChange) {

        let lastContent = previousContent.popLatest() ?? .empty
        let contentChange = OmnibarContentChange(base: lastContent, change: textChange)

        if case .continuation = contentChange {
            self.display(content: contentChange.content)
        }
        
        delegate?.omnibar(
            self,
            contentChange: contentChange,
            method: textChange.method)
    }

    open func focusAndClearText() {

        self.focus()

        guard let fieldEditor = window?.fieldEditor(true, for: self._textField) else { return }
        fieldEditor.delete(self)
    }

    open func focus() {

        self.selectText(nil)
    }

    open func commit() {

        self.delegate?.omnibar(self, commit: self.stringValue)
    }
}


// MARK: - Text Field Adapter

extension Omnibar {

    open override var intrinsicContentSize: NSSize {
        return _textField.intrinsicContentSize
    }

    @IBInspectable open var alignment: NSTextAlignment {
        get { return _textField.alignment }
        set { _textField.alignment = newValue }
    }

    @IBInspectable open var font: NSFont? {
        get { return _textField.font }
        set { _textField.font = newValue }
    }

    @IBInspectable open var placeholder: String? {
        get { return _textField.placeholderString }
        set { _textField.placeholderString = newValue }
    }

    open var stringValue: String {
        get { return _textField.stringValue }
        set { _textField.stringValue = newValue }
    }

    open func selectText(_ sender: Any?) {

        _textField.selectText(sender)
    }

    @IBInspectable open var isEditable: Bool {
        get { return _textField.isEditable }
        set { _textField.isEditable = newValue }
    }

    @IBInspectable open var bezelStyle: NSTextFieldBezelStyle {
        get { return _textField.bezelStyle }
        set { _textField.bezelStyle = newValue }
    }

    @IBInspectable open var isBordered: Bool {
        get { return _textField.isBordered }
        set { _textField.isBordered = newValue }
    }

    open func currentEditor() -> NSText? {
        return _textField.currentEditor()
    }
}

// MARK: NSResponder

extension Omnibar {

    open override var acceptsFirstResponder: Bool {
        return _textField.acceptsFirstResponder
    }

    open override func becomeFirstResponder() -> Bool {
        return _textField.becomeFirstResponder()
    }

    open override func resignFirstResponder() -> Bool {
        return _textField.resignFirstResponder()
    }
}
