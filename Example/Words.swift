//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import struct Foundation.URL
import class Foundation.Bundle

struct Words {

    static let alphabet: [Character] = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]

    static func path(letter: Character) -> String {
        return Bundle.main.path(forResource: "\(letter) Words", ofType: "txt")!
    }

    static func lines(atURL url: URL) throws -> [String] {
        return try String(contentsOf: url, encoding: .utf8).components(separatedBy: "\n")
    }

    static func allWords() throws -> [String] {
        let urls = alphabet.map(Words.path).map(URL.init(fileURLWithPath:))
        let contents = try urls.map(Words.lines(atURL:))
        return contents.reduce([]) { memo, next in memo.appending(contentsOf: next) }
    }
}

extension Array {
    func appending(contentsOf other: [Element]) -> [Element] {
        var result = self
        result.append(contentsOf: other)
        return result
    }
}
