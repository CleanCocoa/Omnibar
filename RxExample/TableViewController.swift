//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import ExampleModel
import RxSwift
import RxCocoa
import RxOmnibar

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    let words = Variable<[Word]>([])

    fileprivate let disposeBag = DisposeBag()

    fileprivate let _selectedWord = PublishSubject<Word>()
    var wordSelectionChange: Observable<Word> {
        return _selectedWord.asObservable()
    }

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

        guard tableView.selectedRow < words.value.count else { return }

        select(row: tableView.selectedRow + 1)
    }

    private func select(row: Int) {
        
        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        tableView.scrollRowToVisible(row)
    }
}
