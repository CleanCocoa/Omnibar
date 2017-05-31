//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa

class TableViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {

    var tableView: NSTableView! { return self.view as? NSTableView }

    lazy var allWords: [String] = { try! Words.allWords() }()

    func numberOfRows(in tableView: NSTableView) -> Int {

        return allWords.count
    }

    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {

        return allWords[row]
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        guard let cellView = tableView.make(withIdentifier: "Cell", owner: tableView) as? NSTableCellView else { return nil }

        cellView.textField?.stringValue = allWords[row]

        return cellView
    }
}
