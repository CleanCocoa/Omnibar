//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit
import Omnibar

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var omnibar: Omnibar!
    @IBOutlet weak var omnibarViewController: OmnibarViewController!
    @IBOutlet weak var tableViewController: TableViewController!

    var filterService: FilterService!
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {

        omnibar.moveFromOmnibar = MoveFromOmnibar(wrapping: tableViewController)
        omnibar.omnibarContentChangeDelegate = omnibarViewController

        filterService = FilterService(
            suggestionDisplay: omnibarViewController,
            wordDisplay: tableViewController)
        omnibarViewController.searchHandler = filterService
        tableViewController.selectWord = SelectWord { [weak omnibarViewController] selectedWord in
            omnibarViewController?.display(selectedWord: selectedWord)
        }
        filterService.displayAll()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

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
        omnibar.display(content: omnibarContent)

        // TODO: select word in table view
        // Search for the base, not the appendix of `.suggestion`s.
        filterService.search(for: omnibarContent.text, offerSuggestion: false)
    }
}
