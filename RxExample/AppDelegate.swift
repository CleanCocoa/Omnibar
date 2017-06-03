//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar
import RxSwift
import RxCocoa
import RxOmnibar

extension RxOmnibarContentChange {
    static var initial: RxOmnibarContentChange {
        return RxOmnibarContentChange(
            contentChange: .replacement(text: ""),
            method: .insertion)
    }
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var omnibar: Omnibar!
    @IBOutlet weak var tableViewController: TableViewController!

    lazy var filterService: FilterService = FilterService()

    let programmaticSearch = PublishSubject<String>()
    let omnibarContentChange = PublishSubject<OmnibarContent>()

    let disposeBag = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        let search = SearchViewModel(
            contentChange: omnibar.rx.contentChange.asObservable(),
            programmaticSearch: programmaticSearch.asObservable().startWith(""))
            .search

        let searchResults = search
            .flatMapLatest(filterService.filter(search:))
            .asDriver(onErrorDriveWith: .empty())

        let searchResultParts = SearchResultParts(searchResults: searchResults)

        // Update Omnibar text

        omnibarContentChange.asDriver(onErrorDriveWith: .empty())
            .drive(omnibar.rx.content)
            .disposed(by: disposeBag)

        let omnibarChange: OmnibarViewModel = {
            let suggestion = searchResultParts.suggestion
            let suggestionContinuation = omnibar.rx.contentChange.asDriver()
                .map(Continuation.init(change:))
                .ignoreNil()
            let selection = tableViewController.wordSelectionChange.asDriver()
                .map(Selection.init(word:))

            return OmnibarViewModel(
                selection: selection,
                suggestion: suggestion,
                continuation: suggestionContinuation)
        }()

        omnibarChange.omnibarContent
            .drive(omnibarContentChange)
            .disposed(by: disposeBag)

        // Update results list

        searchResultParts.words
            .drive(tableViewController.viewModel.words)
            .disposed(by: disposeBag)
        searchResultParts.selectWord
            .drive(tableViewController.viewModel.selection)
            .disposed(by: disposeBag)

        omnibar.rx.moveSelection.asDriver()
            .drive(tableViewController.movementSink)
            .disposed(by: disposeBag)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func focusOmnibar(_ sender: Any) {

        window.makeFirstResponder(omnibar)
    }


    // MARK: Programmatic searches

    @IBAction func testSuggestion(_ sender: Any) {
        changeSearch(omnibarContent: .suggestion(text: "kar", appendix: "ate"))
    }

    @IBAction func testTyping(_ sender: Any) {
        changeSearch(omnibarContent: .prefix(text: "syl"))
    }

    @IBAction func testReplacement(_ sender: Any) {
        changeSearch(omnibarContent: .selection(text: "aardvark"))
    }

    fileprivate func changeSearch(omnibarContent: OmnibarContent) {

        omnibarContentChange.onNext(omnibarContent)

        // Search for the base, not the appendix of `.suggestion`s.
        programmaticSearch.onNext(omnibarContent.text)
    }
}
