//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import ExampleModel
import RxSwift
import RxCocoa
import RxRelay
import RxOmnibar

class TableViewModel {

    let words = BehaviorRelay<[Word]>(value: [])
    let programmaticSelection = BehaviorRelay<Word?>(value: nil)
    fileprivate let manualSelection = PublishSubject<Int>()

    var selectionChange: Observable<Int> {
        let programmaticallySelectedRow = programmaticSelection.asObservable()
            .withLatestFrom(words.asObservable()) { selection, words in (selection, words) }
            .map { selection, words -> Int? in
                guard let selection = selection,
                    let selectionIndex = words.firstIndex(of: selection)
                    else { return nil }

                return selectionIndex
            }

        return manualSelection.asObservable()
            .withLatestFrom(programmaticallySelectedRow) { ($0, $1) }
            .filter { (params: (manual: Int, programmatic: Int?)) in params.manual != params.programmatic }
            .map    { (params: (manual: Int, programmatic: Int?)) in params.manual }
    }

    var selectedWord: Observable<Word> {
        return selectionChange
            .withLatestFrom(words.asObservable()) { index, words in words[index] }
    }
}

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    // Incoming changes
    let viewModel = TableViewModel()
    fileprivate var words: [Word] { return viewModel.words.value }
    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.words.asDriver()
            .drive(onNext: { [unowned self] _ in self.tableView.reloadData() })
            .disposed(by: disposeBag)

        viewModel.selectionChange.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [unowned self] in self.select(row: $0) })
            .disposed(by: disposeBag)
    }

    // Event output
    var wordSelectionChange: ControlEvent<Word> {
        return ControlEvent(events: viewModel.selectedWord.take(until: self.rx.deallocated))
    }


    // MARK: - Table View Contents

    var tableView: NSTableView! { return self.view as? NSTableView }

    func numberOfRows(in tableView: NSTableView) -> Int {

        return words.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

        return words[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let cellView = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "Cell"), owner: tableView) as? NSTableCellView else { return nil }

        cellView.textField?.stringValue = words[row]

        return cellView
    }


    // MARK: Table View Selection

    func tableViewSelectionDidChange(_ notification: Notification) {

        guard let tableView = notification.object as? NSTableView,
            tableView.selectedRow != -1
            else { return }

        viewModel.manualSelection.onNext(tableView.selectedRow)
    }

    var movementSink: AnyObserver<MoveSelection> {
        return AnyObserver { [weak self] event in
            guard case .next(let movement) = event else { return }
            switch movement {
            case .first: self?.selectFirst()
            case .previous: self?.selectPrevious()
            case .next: self?.selectNext()
            case .last: self?.selectLast()
            }
        }
    }

    func selectFirst() {

        guard tableView.numberOfRows > 0 else { return }

        select(row: 0)
    }

    func selectPrevious() {

        guard tableView.selectedRow > 0 else { return }

        select(row: tableView.selectedRow - 1)
    }

    func selectNext() {

        guard tableView.selectedRow < words.count else { return }

        select(row: tableView.selectedRow + 1)
    }

    func selectLast() {

        guard tableView.numberOfRows > 0 else { return }

        select(row: tableView.numberOfRows - 1)
    }

    private func select(row: Int) {
        
        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        tableView.scrollRowToVisible(row)
    }
}
