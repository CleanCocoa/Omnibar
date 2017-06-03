//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import ExampleModel
import RxSwift
import RxCocoa
import RxOmnibar

class TableViewModel {

    let words = Variable<[Word]>([])
    let selection = Variable<Word?>(nil)

    var selectionRow: Observable<Int> {
        return selection.asObservable()
            .withLatestFrom(words.asObservable()) { selection, words in (selection, words) }
            .map { selection, words -> Int? in
                guard let selection = selection,
                    let selectionIndex = words.index(of: selection)
                    else { return nil }

                return selectionIndex
            }.ignoreNil()
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

        viewModel.selectionRow.asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [unowned self] in self.select(row: $0) })
            .disposed(by: disposeBag)
    }

    // Event output
    fileprivate let _selectedWord = PublishSubject<Word>()
    var wordSelectionChange: ControlEvent<Word> {

        let selection = _selectedWord.asObservable()
            .takeUntil(self.rx.deallocated)
        let knownSelection = viewModel.selection.asObservable()
        let changedSelection = selection
            .withLatestFrom(knownSelection) { selected, oldSelection in (selected, oldSelection) }
            .filter { selected, oldSelection in selected != oldSelection }
            .map {  selected, _ in selected }

        return ControlEvent(events: changedSelection)
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

        guard let cellView = tableView.make(withIdentifier: "Cell", owner: tableView) as? NSTableCellView else { return nil }

        cellView.textField?.stringValue = words[row]

        return cellView
    }


    // MARK: Table View Selection

    func tableViewSelectionDidChange(_ notification: Notification) {

        guard let tableView = notification.object as? NSTableView,
            tableView.selectedRow != -1
            else { return }

        let word = words[tableView.selectedRow]
        _selectedWord.onNext(word)
    }

    var movementSink: AnyObserver<MoveSelection> {
        return AnyObserver { [weak self] event in
            guard case .next(let movement) = event else { return }
            switch movement {
            case .next: self?.selectNext()
            case .previous: self?.selectPrevious()
            }
        }
    }

    func selectPrevious() {

        guard tableView.selectedRow > 0 else { return }

        select(row: tableView.selectedRow - 1)
    }

    func selectNext() {

        guard tableView.selectedRow < words.count else { return }

        select(row: tableView.selectedRow + 1)
    }

    private func select(row: Int) {
        
        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        tableView.scrollRowToVisible(row)
    }
}
