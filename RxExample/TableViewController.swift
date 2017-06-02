//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import ExampleModel
import RxSwift
import RxCocoa
import RxOmnibar

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var searchResultSink: UIBindingObserver<TableViewController, SearchResult> {
        return UIBindingObserver(UIElement: self) { tableViewController, searchResult in

            tableViewController.words = searchResult.results

            tableViewController.tableView.reloadData()

            if let suggestion = searchResult.suggestion?.string,
                let selectionIndex = searchResult.results.index(of: suggestion) {

                tableViewController.select(row: selectionIndex)
            }
        }
    }

    fileprivate var words: [Word] = []

    fileprivate let disposeBag = DisposeBag()

    fileprivate let _selectedWord = PublishSubject<Word>()
    var wordSelectionChange: ControlEvent<Word> {
        let source = _selectedWord.asObservable()
            .takeUntil(self.rx.deallocated)
        return ControlEvent(events: source)
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

        guard let tableView = notification.object as? NSTableView else { return }

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
