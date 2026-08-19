//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import Testing
@testable import Omnibar

@Suite("TextFieldTextChange")
struct TextFieldTextChangeTests {

    var irrelevantMethod: ChangeMethod { return .insertion }

    @Test("an empty patch on empty text stays empty")
    func emptyPatchOnEmptyText() {

        #expect(
            TextFieldTextChange(
                oldText: "",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 0, length: 0)),
                method: irrelevantMethod).result
                == "")
        // Range does not matter
        #expect(
            TextFieldTextChange(
                oldText: "",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 0, length: 20)),
                method: irrelevantMethod).result
                == "")
    }

    @Test("a patch on empty text is the patch")
    func patchOnEmptyText() {

        #expect(
            TextFieldTextChange(
                oldText: "",
                patch: TextFieldTextPatch(
                    string: "foo",
                    range: NSRange(location: 0, length: 0)),
                method: irrelevantMethod).result
                == "foo")
        // Range does not matter when original is empty
        #expect(
            TextFieldTextChange(
                oldText: "",
                patch: TextFieldTextPatch(
                    string: "very new",
                    range: NSRange(location: 0, length: 20)),
                method: irrelevantMethod).result
                == "very new")
    }

    @Test("an empty patch of nothing leaves the text alone")
    func emptyPatchOfNothing() {

        #expect(
            TextFieldTextChange(
                oldText: "zettelkasten!!",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 0, length: 0)),
                method: irrelevantMethod).result
                == "zettelkasten!!")
        // Range location does not matter
        #expect(
            TextFieldTextChange(
                oldText: "zettelkasten!!",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 4, length: 0)),
                method: irrelevantMethod).result
                == "zettelkasten!!")
    }

    @Test("an empty patch over a range removes that range")
    func emptyPatchOverRange() {

        #expect(
            TextFieldTextChange(
                oldText: "zettelkasten!!",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 0, length: 6)),
                method: irrelevantMethod).result
                == "kasten!!")
        #expect(
            TextFieldTextChange(
                oldText: "zettelkasten!!",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 4, length: 2)),
                method: irrelevantMethod).result
                == "zettkasten!!")
    }

    @Test("a patch of nothing inserts")
    func patchWithoutRange() {

        #expect(
            TextFieldTextChange(
                oldText: "kasten",
                patch: TextFieldTextPatch(
                    string: "zettel",
                    range: NSRange(location: 0, length: 0)),
                method: irrelevantMethod).result
                == "zettelkasten")
        #expect(
            TextFieldTextChange(
                oldText: "zettel!!1",
                patch: TextFieldTextPatch(
                    string: "kasten",
                    range: NSRange(location: 6, length: 0)),
                method: irrelevantMethod).result
                == "zettelkasten!!1")
    }

    @Test("a patch over a range replaces that range")
    func patchOverRange() {

        #expect(
            TextFieldTextChange(
                oldText: "bierkasten",
                patch: TextFieldTextPatch(
                    string: "zettel",
                    range: NSRange(location: 0, length: 4)),
                method: irrelevantMethod).result
                == "zettelkasten")
        #expect(
            TextFieldTextChange(
                oldText: "hauswirtschaftslehre",
                patch: TextFieldTextPatch(
                    string: "verkaufs",
                    range: NSRange(location: 4, length: 11)),
                method: irrelevantMethod).result
                == "hausverkaufslehre")
    }

}
