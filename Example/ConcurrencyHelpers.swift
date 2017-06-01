//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import Foundation

func delayThread() {
    let seconds = TimeInterval(arc4random_uniform(30)) / 10.0
    NSLog("Thread \"\(Thread.current.description)\" sleeps for \(seconds)s")
    Thread.sleep(forTimeInterval: seconds)
}

/// via <https://gist.github.com/preble/a15245165d914fe7e561>
final class Cancellable<R> {

    private let closure: (R) -> Void
    private var cancelled = false

    init(closure: @escaping (R) -> Void) {

        self.closure = closure
    }

    deinit {

        cancel()
    }

    func cancel() {

        cancelled = true
    }

    func handler(result: R) {

        if cancelled { return }
        
        closure(result)
    }
}
