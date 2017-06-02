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

    let disposeBag = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        searchViewModel = SearchResultsViewModel(
            searchHandler: filterService,
            contentChange: omnibar.rx.contentChange.startWith(RxOmnibarContentChange.initial))

        let searchResults = searchViewModel.searchResults()
            .asDriver(onErrorDriveWith: .empty())
        searchResults.map { $0.results }
            .drive(tableViewController.words)
            .disposed(by: disposeBag)

        contentViewModel = OmnibarContentViewModel(
            wordSelectionChange: tableViewController.wordSelectionChange.asDriver(),
            wordSuggestion: searchResults.map({ $0.suggestion }).ignoreNil())

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

    @IBAction func testSuggestion(_ sender: Any) {
        omnibar.display(content: .suggestion(text: "the quick", appendix: " brown fox"))
    }

    @IBAction func testTyping(_ sender: Any) {
        omnibar.display(content: .prefix(text: "omnia sol"))
    }

    @IBAction func testReplacement(_ sender: Any) {
        omnibar.display(content: .selection(text: "Just Like a Placeholder"))
    }
}
