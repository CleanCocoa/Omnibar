//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import ExampleModel

struct SelectWord {
    let handler: (_ word: Word) -> Void

    init(handler: @escaping (_: Word) -> Void) {
        self.handler = handler
    }

    func select(word: Word) {
        handler(word)
    }

    @inlinable @inline(__always)
    func callAsFunction(word: Word) {
        select(word: word)
    }
}

extension NSUserInterfaceItemIdentifier {
    static var tableCellView: NSUserInterfaceItemIdentifier { return .init(rawValue: "ExTableCellView") }
}

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var selectWord: SelectWord = SelectWord { _ in /* no op */ }

    private var words: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    /// Cache of programmatic selections to avoid sending change events to `selectWord` for these .
    fileprivate var programmaticallySelectedRow: Int?

    // MARK: - Table View Contents

    var tableView: NSTableView! { return self.view as? NSTableView }

    func numberOfRows(in tableView: NSTableView) -> Int {

        return words.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

        return words[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let cellView = tableView.makeView(withIdentifier: .tableCellView, owner: tableView) as? NSTableCellView else { return nil }

        cellView.textField?.stringValue = words[row]

        return cellView
    }


    // MARK: Table View Selection

    func tableViewSelectionDidChange(_ notification: Notification) {

        guard let tableView = notification.object as? NSTableView else { return }

        // Skip programmatic changes
        guard tableView.selectedRow != programmaticallySelectedRow else { return }

        let word = words[tableView.selectedRow]
        selectWord(word: word)
    }
}

extension TableViewController: DisplaysWords {
    func display(words: [Word], selecting selectedWord: Word?) {

        self.words = words
        self.programmaticallySelectedRow = nil

        if let selectedWord = selectedWord,
           let selectionIndex = words.firstIndex(of: selectedWord) {

            programmaticallySelectedRow = selectionIndex
            select(row: selectionIndex)
        }
    }
}

extension TableViewController {
    func selectFirst() {
        select(row: words.indices.first ?? -1)
    }

    func selectLast() {
        select(row: words.indices.last ?? -1)
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
