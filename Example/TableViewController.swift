//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import ExampleModel

protocol SelectsWord: class {
    func select(word: Word)
}

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate, DisplaysWords, SelectsResult {

    weak var wordSelector: SelectsWord?
    
    private var words: [String] = [] {
        didSet {
            tableView.reloadData()
        }
    }

    /// Cache of programmatic selections to avoid change events
    fileprivate var programmaticallySelectedRow: Int?

    func display(words: [Word], selecting selectedWord: Word?) {

        self.words = words
        self.programmaticallySelectedRow = nil

        if let selectedWord = selectedWord,
            let selectionIndex = words.index(of: selectedWord) {

            programmaticallySelectedRow = selectionIndex
            select(row: selectionIndex)
        }
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

        // Skip programmatic changes
        guard tableView.selectedRow != programmaticallySelectedRow else { return }

        let word = words[tableView.selectedRow]
        wordSelector?.select(word: word)
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
