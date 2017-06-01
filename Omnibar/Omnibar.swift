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

    public weak var selectionDelegate: OmnibarSelectionDelegate?
    public weak var contentDelegate: OmnibarContentChangeDelegate?

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
        case #selector(NSResponder.moveDown(_:)):
            selectionDelegate?.omnibarSelectNext?(self)
            return true

        case #selector(NSResponder.moveUp(_:)):
            selectionDelegate?.omnibarSelectPrevious?(self)
            return true

        default: return false
        }
    }

    open override func controlTextDidChange(_ obj: Notification) {

        guard let textField = obj.object as? OmnibarTextField
            else { fatalError("controlTextDidChange expected for OmnibarTextField") }

        guard let textChange = textField.popTextFieldChange()
            else { preconditionFailure("text change setting should precede notification") }

        let lastContent = previousContent.popLatest() ?? .empty
        let contentChange = OmnibarContentChange(base: lastContent, change: textChange)

        if case .continuation = contentChange {
            self.display(content: contentChange.content)
        }
        
        contentDelegate?.omnibar(
            self,
            contentChange: contentChange,
            method: textChange.method)
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
