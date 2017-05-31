//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

public protocol DisplaysOmnibarContent: class {
    func display(content: OmnibarContent)
}

/// Input data model for the Omnibar, setting its contents.
public enum OmnibarContent {

    /// Empties the Omnibar.
    case empty

    /// Display `text` inside the Omnibar and select it all for 
    /// quick overwriting.
    case selection(text: String)

    /// Display `text` inside the Omnibar and put the insertion point
    /// at the end.
    case prefix(text: String)

    /// Display `text`, followed by `appendix`, putting the insertion point
    /// before `appendix` and selecting it so it can be overwritten.
    case suggestion(text: String, appendix: String)

    public var string: String {
        switch self {
        case .empty: return ""
        case let .selection(text: text): return text
        case let .prefix(text: text): return text
        case let .suggestion(text: text, appendix: appendix): return text.appending(appendix)
        }
    }

    public var selectionRange: NSRange {
        switch self {
        case .empty:
            return NSRange(location: 0, length: 0)

        case let .selection(text: text):
            return NSRange(
                location: 0,
                length: (text as NSString).length)

        case let .prefix(text: text):
            return NSRange(
                location: (text as NSString).length,
                length: 0)

        case let .suggestion(text: text, appendix: appendix):
            return NSRange(
                location: (text as NSString).length,
                length: (appendix as NSString).length)
        }
    }
}
