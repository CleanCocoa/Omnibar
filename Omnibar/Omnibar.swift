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

    public struct Insets {

        public let left: CGFloat
        public let right: CGFloat

        public var width: CGFloat { return left + right }

        public init(left: CGFloat, right: CGFloat) {
            self.left = left
            self.right = right
        }
    }

    public weak var delegate: OmnibarDelegate?

    public lazy var _textField: OmnibarTextField = {
        let textField = OmnibarTextField()

        let omnibarCell = OmnibarTextFieldCell(textCell: "")
        omnibarCell.insets = self.textInsets
        textField.cell = omnibarCell

        textField.isEditable = true
        textField.isBezeled = true
        textField.bezelStyle = .squareBezel
        textField.drawsBackground = true

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

    /// Left and right insets of text field where the text may be drawn.
    ///
    /// **Insets affect the field editor, too.** In order to reload
    /// the field editor with updated layout constraints, 
    /// resign first responder and refocus the Omnibar:
    ///
    ///     window.makeFirstResponder(window)
    ///     omnibar.textInsets = newInsets
    ///     window.makeFirstResponder(omnibar)
    ///
    open var textInsets: Insets = Insets(left: 0, right: 0) {
        didSet {
            guard let cell = _textField.cell as? OmnibarTextFieldCell else { return }

            cell.insets = textInsets
            _textField.needsLayout = true
        }
    }

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

        _textField.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(_textField)
        _textField.constrainToSuperviewBounds()

        self.translatesAutoresizingMaskIntoConstraints = false
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

    /// Clears the text so that a change event is fired.
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

    @IBInspectable open override var nextKeyView: NSView? {
        get { return _textField.nextKeyView }
        set { _textField.nextKeyView = newValue }
    }

    open override var nextValidKeyView: NSView? {
        return _textField.nextValidKeyView
    }

    open func selectText(_ sender: Any?) {

        _textField.selectText(sender)
    }

    @IBInspectable open var isEditable: Bool {
        get { return _textField.isEditable }
        set { _textField.isEditable = newValue }
    }

    @IBInspectable open var isBezeled: Bool {
        get { return _textField.isBezeled }
        set { _textField.isBezeled = newValue }
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
