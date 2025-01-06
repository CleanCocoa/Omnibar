//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

public enum OmnibarContentChange: Equatable {

    case replacement(text: String)
    case continuation(text: String, remainingAppendix: String)

    /// The base portion of the content change, i.e. the text typed by the user without any appendices.
    public var text: String {
        switch self {
        case .replacement(text: let text): return text
        case .continuation(text: let text, remainingAppendix: _): return text
        }
    }

    /// The complete string value of the content change, including the suggestion/appendix.
    public var string: String {
        switch self {
        case .replacement(text: let text): return text
        case .continuation(text: let text, remainingAppendix: let appendix): return text + appendix
        }
    }

    var content: OmnibarContent {
        switch self {
        case .replacement(text: let text): return .prefix(text: text)
        case let .continuation(text: text, remainingAppendix: appendix): return .suggestion(text: text, appendix: appendix)
        }
    }
}

extension OmnibarContentChange {
    init(
        base content: OmnibarContent,
        change: TextFieldTextChange
    ) {
        self = {
            switch content {
            case .suggestion
            where change.method == .deletion:
                return .replacement(text: change.result)

            case .suggestion:
                let originalText = content.string
                let newText = change.result

                guard let matchedRange = originalText.prefixRange(of: newText, options: .caseInsensitive)
                else { return .replacement(text: newText) }

                return .continuation(
                    text: change.result,
                    remainingAppendix: originalText.removingSubrange(matchedRange)
                 )

            default:
                return .replacement(text: change.result)
            }
        }()
    }
}
