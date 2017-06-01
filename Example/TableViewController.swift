//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    @IBOutlet weak var omnibarController: OmnibarController!

    lazy var wordsModel: WordsModel = WordsModel()

    func filterResults(searchTerm: String) {

        wordsModel.filter(searchTerm: searchTerm)
        tableView.reloadData()
    }

    // MARK: - Table View Contents

    var tableView: NSTableView! { return self.view as? NSTableView }

    func numberOfRows(in tableView: NSTableView) -> Int {

        return wordsModel.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

        return wordsModel[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let cellView = tableView.make(withIdentifier: "Cell", owner: tableView) as? NSTableCellView else { return nil }

        cellView.textField?.stringValue = wordsModel[row]

        return cellView
    }


    // MARK: Table View Selection

    func tableViewSelectionDidChange(_ notification: Notification) {

        guard let tableView = notification.object as? NSTableView else { return }

        let word = wordsModel[tableView.selectedRow]
        omnibarController.select(string: word)
    }

    func selectPrevious() {

        guard tableView.selectedRow > 0 else { return }

        select(row: tableView.selectedRow - 1)
    }

    func selectNext() {

        guard tableView.selectedRow < wordsModel.count else { return }

        select(row: tableView.selectedRow + 1)
    }

    private func select(row: Int) {

        tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
        tableView.scrollRowToVisible(row)
    }
}
