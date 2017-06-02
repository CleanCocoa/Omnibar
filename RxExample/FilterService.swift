//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import ExampleModel
import RxSwift

protocol DisplaysWords {
    func display(words: [String])
}

class FilterService {

    init() { }

    lazy var wordsModel: WordsModel = WordsModel()
    lazy var filterQueue: DispatchQueue = DispatchQueue(label: "filter-queue", qos: .userInitiated, attributes: .concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.inherit, target: nil)
}

extension FilterService: SearchHandler {

    func search(for searchTerm: String, offerSuggestion: Bool = false) -> Maybe<SearchResult> {

        return Observable.create { observer -> Disposable in

            var cancelled = false

            self.filterQueue.async {
                self.wordsModel.filtered(searchTerm: searchTerm) { result in
//                    delayThread() // uncomment to reveal timing problems

                    guard !cancelled else { observer.onCompleted(); return }

                    if offerSuggestion,
                        let bestFit = result.bestMatch,
                        let suggestion = Suggestion(bestFit: bestFit, forSearchTerm: searchTerm) {

                        observer.onNext(SearchResult(suggestion: suggestion, results: result.words))
                    } else {
                        observer.onNext(SearchResult(suggestion: nil, results: result.words))
                    }

                    observer.on(.completed)
                }
            }

            return Disposables.create { cancelled = true }
        }.asMaybe()
    }
}

struct SearchResult {
    let suggestion: Suggestion?
    let results: [Word]
}

func delayThread() {
    let seconds = TimeInterval(arc4random_uniform(30)) / 10.0
    NSLog("Thread \"\(Thread.current.description)\" sleeps for \(seconds)s")
    Thread.sleep(forTimeInterval: seconds)
}
