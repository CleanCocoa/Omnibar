//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Cocoa
import Omnibar

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var omnibar: Omnibar!
    @IBOutlet weak var omnibarContoller: OmnibarController!

    func applicationDidFinishLaunching(_ aNotification: Notification) {

    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @IBAction func focusOmnibar(_ sender: Any) {

        window.makeFirstResponder(omnibar)
    }
    
    @IBAction func testSuggestion(_ sender: Any) {
        omnibar.display(content: .suggestion(text: "the quick", appendix: " brown fox"))
    }

    @IBAction func testTyping(_ sender: Any) {
        omnibar.display(content: .prefix(text: "omnia sol"))
    }

    @IBAction func testReplacement(_ sender: Any) {
        omnibar.display(content: .selection(text: "Just Like a Placeholder"))
    }
}
