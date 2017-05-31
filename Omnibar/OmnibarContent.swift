//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

/// Input data model for the Omnibar, setting its contents.
public enum OmnibarContent {

    /// Display `text` inside the Omnibar and select it all for 
    /// quick overwriting.
    case selection(text: String)

    /// Display `text` inside the Omnibar and put the insertion point
    /// at the end.
    case prefix(text: String)

    /// Display `text`, followed by `appendix`, putting the insertion point
    /// before `appendix` and selecting it so it can be overwritten.
    case suggestion(text: String, appendix: String)
}
