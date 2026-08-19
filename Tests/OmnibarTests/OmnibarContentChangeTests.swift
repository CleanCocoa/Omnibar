//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Testing
@testable import Omnibar

private let baseText = "same base"
private let appendixText = "continued here"

@Suite("OmnibarContentChange")
struct OmnibarContentChangeTests {

    let irrelevantMethod = ChangeMethod.insertion

    let suggestion = OmnibarContent.suggestion(text: baseText, appendix: appendixText)

    /// The range the appendix occupies after `baseText`.
    let appendixRange = NSRange(
        location: (baseText as NSString).length,
        length: (appendixText as NSString).length)

    func changing(
        _ patch: String,
        at range: NSRange,
        method: ChangeMethod
    ) -> OmnibarContentChange {
        return OmnibarContentChange(
            base: suggestion,
            change: TextFieldTextChange(
                oldText: baseText,
                patch: patch,
                range: range,
                method: method))
    }

    @Test(
        "a base without an appendix yields a replacement",
        arguments: [
            OmnibarContent.empty,
            .selection(text: "irrelevant"),
            .prefix(text: "irrelevant"),
        ])
    func baseWithoutAppendixYieldsReplacement(base: OmnibarContent) {

        let textChange = TextFieldTextChange(
            oldText: "something",
            patch: "patched",
            range: NSRange(location: 2, length: 4),
            method: irrelevantMethod)

        #expect(
            OmnibarContentChange(base: base, change: textChange)
                == .replacement(text: textChange.result))
    }

    @Test("typing the appendix's next character continues the suggestion")
    func appendixContinuedByReplacement() {

        #expect(
            changing("c", at: appendixRange, method: .appending)
                == .continuation(text: "same basec", remainingAppendix: "ontinued here"))
    }

    @Test("deleting into the appendix ends the suggestion")
    func appendixContinuedByDeletion() {

        #expect(
            changing("c", at: appendixRange, method: .deletion)
                == .replacement(text: "same basec"))
    }

    @Test("appending without consuming the appendix continues the suggestion")
    func appendixContinuedWithoutRemoval() {

        #expect(
            changing("c", at: NSRange(location: appendixRange.location, length: 0), method: .appending)
                == .continuation(text: "same basec", remainingAppendix: "ontinued here"))
    }

    @Test("retyping an identical character keeps the suggestion")
    func identicalCharacterReplaced() {

        #expect(
            changing("a", at: NSRange(location: 1, length: 1), method: .insertion)
                == .continuation(text: baseText, remainingAppendix: appendixText))
    }

    @Test("retyping identical characters keeps the suggestion")
    func identicalCharactersReplaced() {

        #expect(
            changing("ame", at: NSRange(location: 1, length: 3), method: .insertion)
                == .continuation(text: baseText, remainingAppendix: appendixText))
    }

    @Test(
        "removing a character mid-text ends the suggestion",
        arguments: [ChangeMethod.insertion, .deletion])
    func characterRemovedMidText(method: ChangeMethod) {

        #expect(
            changing("", at: NSRange(location: 3, length: 1), method: method)
                == .replacement(text: "sam base"))
    }

    @Test("deleting the appendix ends the suggestion")
    func appendixRemovedThroughDeletion() {

        #expect(
            changing("", at: appendixRange, method: .deletion)
                == .replacement(text: baseText))
    }

    @Test("overwriting the appendix with nothing keeps the suggestion")
    func appendixRemovedThroughInsertion() {

        #expect(
            changing("", at: appendixRange, method: .appending)
                == .continuation(text: baseText, remainingAppendix: appendixText))
    }
}
