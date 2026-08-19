//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Testing
@testable import Omnibar

@Suite("TextFieldTextChange")
struct TextFieldTextChangeTests {

    let irrelevantMethod = ChangeMethod.insertion

    func result(_ oldText: String, patch: String, at range: NSRange) -> String {
        return TextFieldTextChange(
            oldText: oldText,
            patch: patch,
            range: range,
            method: irrelevantMethod).result
    }

    @Test("an empty patch on empty text stays empty")
    func emptyPatchOnEmptyText() {

        #expect(result("", patch: "", at: NSRange(location: 0, length: 0)) == "")
        // Range does not matter
        #expect(result("", patch: "", at: NSRange(location: 0, length: 20)) == "")
    }

    @Test("a patch on empty text is the patch")
    func patchOnEmptyText() {

        #expect(result("", patch: "foo", at: NSRange(location: 0, length: 0)) == "foo")
        // Range does not matter when original is empty
        #expect(result("", patch: "very new", at: NSRange(location: 0, length: 20)) == "very new")
    }

    @Test("an empty patch of nothing leaves the text alone")
    func emptyPatchOfNothing() {

        #expect(result("zettelkasten!!", patch: "", at: NSRange(location: 0, length: 0)) == "zettelkasten!!")
        // Range location does not matter
        #expect(result("zettelkasten!!", patch: "", at: NSRange(location: 4, length: 0)) == "zettelkasten!!")
    }

    @Test("an empty patch over a range removes that range")
    func emptyPatchOverRange() {

        #expect(result("zettelkasten!!", patch: "", at: NSRange(location: 0, length: 6)) == "kasten!!")
        #expect(result("zettelkasten!!", patch: "", at: NSRange(location: 4, length: 2)) == "zettkasten!!")
    }

    @Test("a patch of nothing inserts")
    func patchWithoutRange() {

        #expect(result("kasten", patch: "zettel", at: NSRange(location: 0, length: 0)) == "zettelkasten")
        #expect(result("zettel!!1", patch: "kasten", at: NSRange(location: 6, length: 0)) == "zettelkasten!!1")
    }

    @Test("a patch over a range replaces that range")
    func patchOverRange() {

        #expect(result("bierkasten", patch: "zettel", at: NSRange(location: 0, length: 4)) == "zettelkasten")
        #expect(result("hauswirtschaftslehre", patch: "verkaufs", at: NSRange(location: 4, length: 11)) == "hausverkaufslehre")
    }
}
