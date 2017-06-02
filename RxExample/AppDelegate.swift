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

    var viewModel: OmnibarViewModel!
    let disposeBag = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        tableViewController.wordSelectionChange
            .map { OmnibarContent.selection(text: $0) }
            .bind(to: omnibar.rx.content)
            .disposed(by: disposeBag)

        omnibar.rx.moveSelection
            .bind(to: tableViewController.movementSink)
            .disposed(by: disposeBag)

        viewModel = OmnibarViewModel(
            searchHandler: filterService,
            contentChange: omnibar.rx.contentChange.asObservable().startWith(RxOmnibarContentChange.initial))

        let searchResults = viewModel.searchResults()
            .asDriver(onErrorDriveWith: .empty())
        searchResults.map { $0.suggestion }
            .ignoreNil()
            .map { $0.omnibarContent }
            .drive(omnibar.rx.content)
            .disposed(by: disposeBag)
        searchResults.map { $0.results }
            .drive(tableViewController.words)
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
