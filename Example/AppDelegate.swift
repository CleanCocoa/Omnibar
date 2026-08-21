//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import AppKit
import Omnibar

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var omnibar: Omnibar!
    @IBOutlet weak var omnibarViewController: OmnibarViewController!
    @IBOutlet weak var tableViewController: TableViewController!

    var filterService: FilterService!

    private var observation: Task<Void, Never>?

    func applicationDidFinishLaunching(_ aNotification: Notification) {

        filterService = FilterService(
            suggestionDisplay: omnibarViewController,
            wordDisplay: tableViewController)
        tableViewController.selectWord = SelectWord { [weak omnibarViewController] selectedWord in
            omnibarViewController?.display(selectedWord: selectedWord)
        }

        let events = omnibar.events()
        self.observation = Task { [weak self] in
            for await event in events {
                self?.handle(event)
            }
        }

        filterService.displayAll()
    }

    private func handle(_ event: OmnibarEvent) {

        switch event {
        case let .contentChange(contentChange, method):
            guard method != .programmaticReplacement else { break }
            filterService.search(
                for: contentChange.text,
                offerSuggestion: method == .appending)

        case let .commit(text):
            omnibarViewController.confirm(text: text)

        case let .movement(movementEvent):
            tableViewController.move(movementEvent)

        case .cancel:
            break
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {

        observation?.cancel()
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
