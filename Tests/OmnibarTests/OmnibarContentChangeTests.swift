//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Testing
@testable import Omnibar

@Suite("OmnibarContentChange")
struct OmnibarContentChangeTests {

    var irrelevantMethod: ChangeMethod { return .insertion }

    @Test("an empty base yields a replacement")
    func emptyBaseYieldsReplacement() {

        let textChange = TextFieldTextChange(oldText: "something", patch: "patched", range: NSRange(location: 2, length: 4), method: irrelevantMethod)

        #expect(
            OmnibarContentChange(base: .empty, change: textChange)
                == .replacement(text: textChange.result))
    }

    @Test("a selection base yields a replacement")
    func selectionBaseYieldsReplacement() {

        let textChange = TextFieldTextChange(oldText: "the change", patch: "xoxo", range: NSRange(location: 3, length: 1), method: irrelevantMethod)

        #expect(
            OmnibarContentChange(base: .selection(text: "irrelevant"), change: textChange)
                == .replacement(text: textChange.result))
    }

    @Test("a prefix base yields a replacement")
    func prefixBaseYieldsReplacement() {

        let textChange = TextFieldTextChange(oldText: "outdated", patch: "material", range: NSRange(location: 2, length: 4), method: irrelevantMethod)

        #expect(
            OmnibarContentChange(base: .prefix(text: "irrelevant"), change: textChange)
                == .replacement(text: textChange.result))
    }

    @Test("typing the appendix's next character continues the suggestion")
    func appendixContinuedByReplacement() {

        let continuingAppendix = TextFieldTextChange(
            oldText: "same base",
            patch: "c",
            range: NSRange(
                location: ("same base" as NSString).length,
                length: ("continued here" as NSString).length),
            method: .appending)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: continuingAppendix)
                == .continuation(text: "same basec", remainingAppendix: "ontinued here"))
    }

    @Test("deleting into the appendix ends the suggestion")
    func appendixContinuedByDeletion() {

        let removingFromAppendix = TextFieldTextChange(
            oldText: "same base",
            patch: "c",
            range: NSRange(
                location: ("same base" as NSString).length,
                length: ("continued here" as NSString).length),
            method: .deletion)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removingFromAppendix)
                == .replacement(text: "same basec"))
    }

    @Test("appending without consuming the appendix continues the suggestion")
    func appendixContinuedWithoutRemoval() {

        let appendingFitting = TextFieldTextChange(
            oldText: "same base",
            patch: "c",
            range: NSRange(location: ("same base" as NSString).length, length: 0),
            method: .appending)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: appendingFitting)
                == .continuation(text: "same basec", remainingAppendix: "ontinued here"))
    }

    @Test("retyping an identical character keeps the suggestion")
    func identicalCharacterReplaced() {

        let identicalReplacement = TextFieldTextChange(
            oldText: "same base",
            patch: "a",
            range: NSRange(location: 1, length: 1),
            method: .insertion)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: identicalReplacement)
                == .continuation(text: "same base", remainingAppendix: "continued here"))
    }

    @Test("retyping identical characters keeps the suggestion")
    func identicalCharactersReplaced() {

        let identicalReplacement = TextFieldTextChange(
            oldText: "same base",
            patch: "ame",
            range: NSRange(location: 1, length: 3),
            method: .insertion)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: identicalReplacement)
                == .continuation(text: "same base", remainingAppendix: "continued here"))
    }

    @Test("removing a character mid-text through insertion ends the suggestion")
    func characterRemovedThroughInsertion() {

        let removal = TextFieldTextChange(
            oldText: "same base",
            patch: "",
            range: NSRange(location: 3, length: 1),
            method: .insertion)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removal)
                == .replacement(text: removal.result))
    }

    @Test("removing a character mid-text through deletion ends the suggestion")
    func characterRemovedThroughDeletion() {

        let removal = TextFieldTextChange(
            oldText: "same base",
            patch: "",
            range: NSRange(location: 3, length: 1),
            method: .deletion)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removal)
                == .replacement(text: removal.result))
    }

    @Test("deleting the appendix ends the suggestion")
    func appendixRemovedThroughDeletion() {

        let removal = TextFieldTextChange(
            oldText: "same base",
            patch: "",
            range: NSRange(
                location: ("same base" as NSString).length,
                length: ("continued here" as NSString).length),
            method: .deletion)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removal)
                == .replacement(text: "same base"))
    }

    @Test("overwriting the appendix with nothing keeps the suggestion")
    func appendixRemovedThroughInsertion() {

        let removal = TextFieldTextChange(
            oldText: "same base",
            patch: "",
            range: NSRange(
                location: ("same base" as NSString).length,
                length: ("continued here" as NSString).length),
            method: .appending)

        #expect(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removal)
                == .continuation(text: "same base", remainingAppendix: "continued here"))
    }

}
