//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Testing
@testable import Omnibar

@Suite("OmnibarContent")
struct OmnibarContentTests {

    @Test("string includes the suggestion appendix")
    func stringValue() {
        #expect(OmnibarContent.empty.string == "")
        #expect(OmnibarContent.prefix(text: "foo bar").string == "foo bar")
        #expect(OmnibarContent.selection(text: "selecione textual").string == "selecione textual")
        #expect(OmnibarContent.suggestion(text: "only text", appendix: "").string == "only text")
        #expect(OmnibarContent.suggestion(text: "more than text", appendix: "like this").string == "more than textlike this")
    }

    @Test("selectionRange selects what the user is expected to overwrite")
    func selectionRange() {
        #expect(OmnibarContent.empty.selectionRange == NSRange(location: 0, length: 0))
        #expect(
            OmnibarContent.prefix(text: "foo bar").selectionRange
                == NSRange(location: ("foo bar" as NSString).length, length: 0))
        #expect(
            OmnibarContent.selection(text: "selecione textual").selectionRange
                == NSRange(location: 0, length: ("selecione textual" as NSString).length))
        #expect(
            OmnibarContent.suggestion(text: "only text", appendix: "").selectionRange
                == NSRange(location: ("only text" as NSString).length, length: 0))
        #expect(
            OmnibarContent.suggestion(text: "more than text", appendix: "like this").selectionRange
                == NSRange(location: ("more than text" as NSString).length,
                           length: ("like this" as NSString).length))
    }
}
