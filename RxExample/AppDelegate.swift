//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar
import RxSwift
import RxCocoa
import RxOmnibar
import ExampleModel

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var omnibar: Omnibar!
    @IBOutlet weak var tableViewController: TableViewController!

    let programmaticSearch = PublishSubject<String>()
    let omnibarContentChanges = PublishSubject<OmnibarContent>()
    let disposeBag = DisposeBag()

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        wireComponents()
    }
}


// MARK: - Rx Wiring

extension AppDelegate {

    func wireComponents() {

        let searchInput = AppViewModel.OmnibarInput.SearchInput(
            typedSearches: self.omnibar.rx.contentChange.asDriver(),
            programmaticSearches: self.programmaticSearch.asObservable().startWith(""),
            wordsModels: Observable.just(WordsModel()))
        let selectionInput = AppViewModel.OmnibarInput.SelectionInput(
            wordSelections: self.tableViewController.wordSelectionChange.asDriver())
        let (omnibarViewModel, resultParts) = AppViewModel().transform(
            searchInput: searchInput,
            selectionInput: selectionInput)
        let selectionMovements = self.omnibar.rx.moveSelection.asDriver()

        updateOmnibar(viewModel: omnibarViewModel)
        updateResultsList(fromParts: resultParts)
        adjustSelection(movingWith: selectionMovements)

        omnibar.rx.commits.asDriver()
            .drive(commitAlertSink)
            .disposed(by: disposeBag)
    }

    var commitAlertSink: AnyObserver<String> {
        return AnyObserver { event in
            guard case .next(let text) = event else { return }

            let alert = NSAlert()
            alert.messageText = text
            alert.addButton(withTitle: "Continue")
            alert.runModal()
        }
    }

    private func adjustSelection(movingWith moveSignal: Driver<MoveSelection>) {

        moveSignal
            .drive(self.tableViewController.movementSink)
            .disposed(by: disposeBag)
    }

    private func updateOmnibar(viewModel: OmnibarViewModel) {

        viewModel.omnibarContentResponse
            .drive(self.omnibar.rx.contentResponseSink)
            .disposed(by: disposeBag)

        // Buffer these for button-driven changes
        viewModel.omnibarContent
            .drive(self.omnibarContentChanges)
            .disposed(by: disposeBag)
        self.omnibarContentChanges.asDriver(onErrorDriveWith: .empty())
            .drive(self.omnibar.rx.content)
            .disposed(by: disposeBag)
    }

    private func updateResultsList(fromParts parts: SearchResultParts) {

        parts.words
            .drive(self.tableViewController.viewModel.words)
            .disposed(by: disposeBag)
        parts.selectWord
            .drive(self.tableViewController.viewModel.programmaticSelection)
            .disposed(by: disposeBag)
    }
}


// MARK: - IB Actions

extension AppDelegate {

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

        omnibarContentChanges.onNext(omnibarContent)

        // Search for the base, not the appendix of `.suggestion`s.
        programmaticSearch.onNext(omnibarContent.text)
    }
}
