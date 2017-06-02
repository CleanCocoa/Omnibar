//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import ExampleModel
import RxSwift
import RxCocoa

protocol SelectsWord: class {
    func select(word: Word)
}

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate,  SelectsResult {

    weak var wordSelector: SelectsWord?

    let words = Variable<[Word]>([])

    fileprivate let disposeBag = DisposeBag()

    override func viewDidLoad() {

        super.viewDidLoad()

        words.asDriver()
            .drive(onNext: { [unowned self]_ in
                self.tableView.reloadData() })
            .disposed(by: disposeBag)
    }


    // MARK: - Table View Contents

    var tableView: NSTableView! { return self.view as? NSTableView }

    func numberOfRows(in tableView: NSTableView) -> Int {

        return words.value.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

        return words.value[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let cellView = tableView.make(withIdentifier: "Cell", owner: tableView) as? NSTableCellView else { return nil }

        cellView.textField?.stringValue = words.value[row]

        return cellView
    }


    // MARK: Table View Selection

    func tableViewSelectionDidChange(_ notification: Notification) {

        guard let tableView = notification.object as? NSTableView else { return }

        let word = words.value[tableView.selectedRow]
        wordSelector?.select(word: word)
    }

    func selectPrevious() {

        guard tableView.selectedRow > 0 else { return }

        select(row: tableView.selectedRow - 1)
    }

    func selectNext() {

        guard tableView.selectedRow < words.value.count else { return }

        select(row: tableView.selectedRow + 1)
    }

    private func select(row: Int) {
        
        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        tableView.scrollRowToVisible(row)
    }
}
