//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

extension NSTextField: TextReplaceable { }

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
public class Omnibar: NSTextField {

    public struct Insets {

        public let left: CGFloat
        public let right: CGFloat

        public var width: CGFloat { return left + right }

        public init(left: CGFloat, right: CGFloat) {
            self.left = left
            self.right = right
        }
    }

    public var moveFromOmnibar: MoveFromOmnibar?
    public weak var omnibarContentChangeDelegate: OmnibarContentChangeDelegate?
    fileprivate var cachedTextFieldChange: TextFieldTextChange?

    /// Testing seam.
    var editableText: TextReplaceable { return self }

    /// Display model cache.
    let previousContent = PreviousContent()

    /// Enable/disable resetting the contents with the Esc key. `True` by default.
    public var isResettable: Bool = true

    /// If clearing/Esc events should always fire, even if the Omnibar was empty before and no actual text change occured. `True` by default to trigger events when you hit Esc multiple times.
    public var alwaysFireWhenClearingText: Bool = true

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
    public var textInsets: Insets = Insets(left: 0, right: 0) {
        didSet {
            guard let cell = self.cell as? OmnibarTextFieldCell else { return }

            cell.insets = textInsets
            self.needsLayout = true
        }
    }

    // MARK: - Initialization

    public convenience init() {
        self.init(frame: NSRect.zero)
    }

    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    fileprivate var controlTextChangeSubscription: Any?

    private func setup() {
        let omnibarCell = OmnibarTextFieldCell(textCell: "")
        omnibarCell.insets = self.textInsets
        omnibarCell.isScrollable = true
        self.cell = omnibarCell

        self.alignment = .natural
        self.isEditable = true
        self.isBezeled = true
        self.bezelStyle = .squareBezel
        self.drawsBackground = true

        self.usesSingleLineMode = true
    }

    deinit {
        if let subscription = controlTextChangeSubscription {
            NotificationCenter.default.removeObserver(subscription)
        }
    }
}


// MARK: - Input

extension Omnibar {
    public func display(content: OmnibarContent) {
        editableText.replaceText(replacement: TextReplacement(omnibarContent: content))

        // Update cache
        previousContent.pushLatest(content)
    }
}


// MARK: - Output

extension Omnibar {

    public func doOmnibarCommand(commandSelector: Selector) -> Bool {

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

        // MARK: Shift+Arrow Keys

        case #selector(NSResponder.moveToBeginningOfDocumentAndModifySelection(_:)),
             #selector(NSResponder.moveToBeginningOfParagraphAndModifySelection(_:)):
            moveFromOmnibar?(movement: .top, expandingSelection: true)
            return true

        case #selector(NSResponder.moveUpAndModifySelection(_:)):
            moveFromOmnibar?(movement: .up, expandingSelection: true)
            return true

        case #selector(NSResponder.moveDownAndModifySelection(_:)):
            moveFromOmnibar?(movement: .down, expandingSelection: true)
            return true

        case #selector(NSResponder.moveToEndOfDocumentAndModifySelection(_:)),
             #selector(NSResponder.moveToEndOfParagraphAndModifySelection(_:)):
            moveFromOmnibar?(movement: .bottom, expandingSelection: true)
            return true

        // MARK: Arrow Keys

        case #selector(NSResponder.moveToBeginningOfDocument(_:)):
            moveFromOmnibar?(movement: .top)
            return true

        case #selector(NSResponder.moveUp(_:)):
            moveFromOmnibar?(movement: .up)
            return true

        case #selector(NSResponder.moveDown(_:)):
            moveFromOmnibar?(movement: .down)
            return true

        case #selector(NSResponder.moveToEndOfDocument(_:)):
            moveFromOmnibar?(movement: .bottom)
            return true

        default:
            return false
        }
    }

    public override func textDidChange(_ notification: Notification) {
        super.textDidChange(notification)
        
        // textDidChange(_:) fires twice when you paste "\n" inside: once for the original,
        // and once for the replacement, but our delegate method will only be called one time.
        guard let textChange = self.popTextFieldChange() else { return }

        processTextChange(textChange)
    }

    func processTextChange(_ textChange: TextFieldTextChange) {

        let lastContent = previousContent.popLatest() ?? .empty
        let contentChange = OmnibarContentChange(base: lastContent, change: textChange)

        if case .continuation = contentChange {
            self.display(content: contentChange.content)
        }
        
        omnibarContentChangeDelegate?.omnibar(
            self,
            didChangeContent: contentChange,
            method: textChange.method
        )
    }

    /// Clears the text so that a change event is fired.
    public func focusAndClearText() {

        self.focus()

        // Clearing the editor produces the text change event -- iff the editor was non-empty before. We want clear-text events to be triggered in all cases, though.
        if let fieldEditor = window?.fieldEditor(true, for: self) {
            if fieldEditor.string.isEmpty && self.alwaysFireWhenClearingText {
                self.omnibarContentChangeDelegate?.omnibar(
                    self,
                    didChangeContent: .replacement(text: ""),
                    method: .deletion
                )
            } else {
                fieldEditor.delete(self)
            }
        }

        self.omnibarContentChangeDelegate?.omnibarDidCancelOperation(self)
    }

    public func focus() {

        self.selectText(nil)
    }

    public func commit() {

        self.omnibarContentChangeDelegate?.omnibar(self, commit: self.stringValue)
    }
}

// MARK: - Typing

// A `NSTextField` is the delegate of the field editor by
// default if it conforms to `NSTextViewDelegate`.

extension Omnibar: NSTextViewDelegate {

    func popTextFieldChange() -> TextFieldTextChange? {

        let value = cachedTextFieldChange
        cachedTextFieldChange = nil
        return value
    }

    public func textView(_ textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String?) -> Bool {

        // `replacementString` is `nil` on attribute changes only, which we ignore,
        // but equals "" on deletion.
        if let replacement = replacementString {
            self.cacheTextFieldChange(
                textView: textView,
                shouldChangeTextIn: affectedCharRange,
                replacementString: replacement)
        }

        guard let cellAsDelegate = self.cell as? NSTextViewDelegate,
              cellAsDelegate.responds(to: #selector(NSTextViewDelegate.textView(_:shouldChangeTextIn:replacementString:)))
        else { return false }
        return cellAsDelegate.textView!(textView, shouldChangeTextIn: affectedCharRange, replacementString: replacementString)
    }

    private func cacheTextFieldChange(textView: NSTextView, shouldChangeTextIn affectedCharRange: NSRange, replacementString: String) {

        let oldText = textView.string
        let method = ChangeMethod(
            original: oldText as NSString,
            replacement: replacementString as NSString,
            affectedRange: affectedCharRange)

        self.cachedTextFieldChange = TextFieldTextChange(
            oldText: oldText,
            patch: TextFieldTextPatch(
                string: replacementString,
                range: affectedCharRange),
            method: method)
    }

    public func textView(_ textView: NSTextView, doCommandBy commandSelector: Selector) -> Bool {

        if doOmnibarCommand(commandSelector: commandSelector) {
            return true
        }

        return self.delegate?.control?(self, textView: textView, doCommandBy: commandSelector)
            ?? false
    }
}
