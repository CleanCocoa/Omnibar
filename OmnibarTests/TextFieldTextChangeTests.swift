//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
@testable import Omnibar

class TextFieldTextChangeTests: XCTestCase {

    func testPatchResult_EmptyString_EmptyPatch_IsEmptyString() {

        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 0, length: 0))).result,
            "")
        // Range does not matter
        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 0, length: 20))).result,
            "")
    }

    func testPatchResult_EmptyString_WithPatch_IsPatchString() {

        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "",
                patch: TextFieldTextPatch(
                    string: "foo",
                    range: NSRange(location: 0, length: 0))).result,
            "foo")
        // Range does not matter when original is empty
        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "",
                patch: TextFieldTextPatch(
                    string: "very new",
                    range: NSRange(location: 0, length: 20))).result,
            "very new")
    }

    func testPatchResult_ContentfulOriginal_EmptyPatch_IsOriginal() {

        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "zettelkasten!!",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 0, length: 0))).result,
            "zettelkasten!!")
        // Range location does not matter
        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "zettelkasten!!",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 4, length: 0))).result,
            "zettelkasten!!")
    }

    func testPatchResult_ContentfulOriginal_EmptyPatchWithLength_RemovesFromOriginal() {

        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "zettelkasten!!",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 0, length: 6))).result,
            "kasten!!")
        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "zettelkasten!!",
                patch: TextFieldTextPatch(
                    string: "",
                    range: NSRange(location: 4, length: 2))).result,
            "zettkasten!!")
    }

    func testPatchResult_ContentfulOriginal_PatchReplacementWithoutLength_InsertsPatch() {

        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "kasten",
                patch: TextFieldTextPatch(
                    string: "zettel",
                    range: NSRange(location: 0, length: 0))).result,
            "zettelkasten")
        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "zettel!!1",
                patch: TextFieldTextPatch(
                    string: "kasten",
                    range: NSRange(location: 6, length: 0))).result,
            "zettelkasten!!1")
    }

    func testPatchResult_ContentfulOriginal_PatchReplacementWitLength_ReplacesOriginalWithPatchInRange() {

        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "bierkasten",
                patch: TextFieldTextPatch(
                    string: "zettel",
                    range: NSRange(location: 0, length: 4))).result,
            "zettelkasten")
        XCTAssertEqual(
            TextFieldTextChange(
                oldText: "hauswirtschaftslehre",
                patch: TextFieldTextPatch(
                    string: "verkaufs",
                    range: NSRange(location: 4, length: 11))).result,
            "hausverkaufslehre")
    }

}
