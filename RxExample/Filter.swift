//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation
import ExampleModel
import RxSwift

struct Filter {

    let searches: Observable<Search>
    let wordsModels: Observable<WordsModel>

    let filterQueue: DispatchQueue = DispatchQueue(
        label: "filter-queue",
        qos: .userInitiated,
        attributes: .concurrent,
        autoreleaseFrequency: .inherit,
        target: nil)

    var searchResults: Observable<SearchResult> {
        return searches
            .withLatestFrom(wordsModels) { search, wordsModel in (search, wordsModel) }
            .flatMapLatest(filter(filterQueue: self.filterQueue))
    }
}

fileprivate func filter(filterQueue: DispatchQueue) -> (Search, WordsModel) -> Maybe<SearchResult> {

    return { search, wordsModel in

        return Observable.create { observer in

            var cancelled = false

            filterQueue.async {
                wordsModel.filtered(searchTerm: search.searchTerm) { result in
//                    delayThread() // uncomment to reveal timing problems

                    guard !cancelled else { observer.onCompleted(); return }

                    if search.requestSuggestion,
                        let bestFit = result.bestMatch,
                        let suggestion = Suggestion(bestFit: bestFit, forSearchTerm: search.searchTerm, requestNumber: search.requestNumber) {

                        observer.onNext(SearchResult(suggestion: suggestion, results: result.words))
                    } else {
                        observer.onNext(SearchResult(suggestion: Suggestion(onlySearchTerm: search.searchTerm,requestNumber: search.requestNumber), results: result.words))
                    }

                    observer.on(.completed)
                }
            }

            return Disposables.create { cancelled = true }
        }.asMaybe()
    }
}

func delayThread() {
    let seconds = TimeInterval(arc4random_uniform(30)) / 10.0
    NSLog("Thread \"\(Thread.current.description)\" sleeps for \(seconds)s")
    Thread.sleep(forTimeInterval: seconds)
}
