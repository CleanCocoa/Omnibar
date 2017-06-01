//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import Omnibar

class OmnibarContentChangeTests: XCTestCase {

    var irrelevantMethod: ChangeMethod { return .insertion }

    func testInit_EmptyBase_ReturnsReplacement() {

        let textChange = TextFieldTextChange(oldText: "something", patch: "patched", range: NSRange(location: 2, length: 4), method: irrelevantMethod)

        XCTAssertEqual(
            OmnibarContentChange(base: .empty, change: textChange),
            .replacement(text: textChange.result))
    }

    func testInit_SelectionBase_ReturnsReplacement() {

        let textChange = TextFieldTextChange(oldText: "the change", patch: "xoxo", range: NSRange(location: 3, length: 1), method: irrelevantMethod)

        XCTAssertEqual(
            OmnibarContentChange(base: .selection(text: "irrelevant"), change: textChange),
            .replacement(text: textChange.result))
    }

    func testInit_PrefixBase_ReturnsReplacement() {

        let textChange = TextFieldTextChange(oldText: "outdated", patch: "material", range: NSRange(location: 2, length: 4), method: irrelevantMethod)

        XCTAssertEqual(
            OmnibarContentChange(base: .prefix(text: "irrelevant"), change: textChange),
            .replacement(text: textChange.result))
    }

    func testInit_SuggestionBase_ChangeContinuesAppendixByReplacement_ReturnsContinuation() {

        let continuingAppendix = TextFieldTextChange(
            oldText: "same base",
            patch: "c",
            range: NSRange(
                location: ("same base" as NSString).length,
                length: ("continued here" as NSString).length),
            method: .insertion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: continuingAppendix),
            .continuation(text: "same basec", remainingAppendix: "ontinued here"))
    }

    func testInit_SuggestionBase_ChangeContinuesAppendixByDeletion_ReturnsReplacement() {

        let removingFromAppendix = TextFieldTextChange(
            oldText: "same base",
            patch: "c",
            range: NSRange(
                location: ("same base" as NSString).length,
                length: ("continued here" as NSString).length),
            method: .deletion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removingFromAppendix),
            .replacement(text: "same basec"))
    }

    func testInit_SuggestionBase_ChangeContinuesAppendixWithoutRemovingAppendix_ReturnsContinuation() {

        let appendingFitting = TextFieldTextChange(
            oldText: "same base",
            patch: "c",
            range: NSRange(location: ("same base" as NSString).length, length: 0),
            method: .insertion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: appendingFitting),
            .continuation(text: "same basec", remainingAppendix: "ontinued here"))
    }

    func testInit_SuggestionBase_ChangeReplacesIdenticalCharInBetween_ReturnsContinuation() {

        let identicalReplacement = TextFieldTextChange(
            oldText: "same base",
            patch: "a",
            range: NSRange(location: 1, length: 1),
            method: .insertion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: identicalReplacement),
            .continuation(text: "same base", remainingAppendix: "continued here"))
    }

    func testInit_SuggestionBase_ChangeReplaces2IdenticalCharsInBetween_ReturnsContinuation() {

        let identicalReplacement = TextFieldTextChange(
            oldText: "same base",
            patch: "ame",
            range: NSRange(location: 1, length: 3),
            method: .insertion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: identicalReplacement),
            .continuation(text: "same base", remainingAppendix: "continued here"))
    }

    func testInit_SuggestionBase_ChangeRemovesCharacterInBetween_ThroughInsertion_ReturnsReplacement() {

        let removal = TextFieldTextChange(
            oldText: "same base",
            patch: "",
            range: NSRange(location: 3, length: 1),
            method: .insertion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removal),
            .replacement(text: removal.result))
    }

    func testInit_SuggestionBase_ChangeRemovesCharacterInBetween_ThroughDeletion_ReturnsReplacement() {

        let removal = TextFieldTextChange(
            oldText: "same base",
            patch: "",
            range: NSRange(location: 3, length: 1),
            method: .deletion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removal),
            .replacement(text: removal.result))
    }

    func testInit_SuggestionBase_ChangeRemovesAppendix_ThroughDeletion_ReturnsReplacement() {

        let removal = TextFieldTextChange(
            oldText: "same base",
            patch: "",
            range: NSRange(
                location: ("same base" as NSString).length,
                length: ("continued here" as NSString).length),
            method: .deletion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removal),
            .replacement(text: "same base"))
    }

    func testInit_SuggestionBase_ChangeRemovesAppendix_ThroughInsertion_ReturnsReplacement() {

        let removal = TextFieldTextChange(
            oldText: "same base",
            patch: "",
            range: NSRange(
                location: ("same base" as NSString).length,
                length: ("continued here" as NSString).length),
            method: .insertion)

        XCTAssertEqual(
            OmnibarContentChange(base: .suggestion(text: "same base", appendix: "continued here"), change: removal),
            .continuation(text: "same base", remainingAppendix: "continued here"))
    }

}
