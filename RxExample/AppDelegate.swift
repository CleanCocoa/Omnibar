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

    var searchViewModel: SearchResultsViewModel!
    var contentViewModel: OmnibarContentViewModel!
    let programmaticSearch = PublishSubject<String>()

    let disposeBag = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        searchViewModel = SearchResultsViewModel(
            searchHandler: filterService,
            contentChange: omnibar.rx.contentChange.asObservable(),
            programmaticSearch: programmaticSearch.asObservable().startWith(""))

        let searchResults = searchViewModel.searchResults().asDriver(onErrorDriveWith: .empty())

        contentViewModel = OmnibarContentViewModel(
            wordSelectionChange: tableViewController.wordSelectionChange.asDriver(),
            wordSuggestion: searchResults.map({ $0.suggestion }).ignoreNil())

        searchResults.map { $0.results }
            .drive(tableViewController.words)
            .disposed(by: disposeBag)

        contentViewModel.omnibarContent
            .drive(omnibar.rx.content)
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

        omnibar.rx.content.onNext(omnibarContent)

        // Search for the base, not the appendix of `.suggestion`s.
        programmaticSearch.onNext(omnibarContent.text)
    }
}
