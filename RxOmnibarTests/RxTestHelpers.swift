//  Copyright © 2017 Christian Tietze. All rights reserved. Distributed under the MIT License.

import XCTest
import RxSwift
import RxCocoa

protocol RxTestHelpers {}

extension RxTestHelpers {

    func ensurePropertyDeallocated<C, T: Equatable>(_ createControl: () -> C, _ initialValue: T, file: StaticString = #file, line: UInt = #line, _ propertySelector: (C) -> ControlProperty<T>) where C: NSObject {

        ensurePropertyDeallocated(createControl, initialValue, comparer: ==, file: file, line: line, propertySelector)
    }

    func ensurePropertyDeallocated<C, T>(_ createControl: () -> C, _ initialValue: T, comparer: (T, T) -> Bool, file: StaticString = #file, line: UInt = #line, _ propertySelector: (C) -> ControlProperty<T>) where C: NSObject  {

        let relay = BehaviorRelay(value: initialValue)

        var completed = false
        var deallocated = false
        var lastReturnedPropertyValue: T!

        autoreleasepool {
            var control: C! = createControl()

            let property = propertySelector(control)

            let disposable = relay.asObservable().bind(to: property)

            _ = property.subscribe(onNext: { n in
                lastReturnedPropertyValue = n
            }, onCompleted: {
                completed = true
                disposable.dispose()
            })


            _ = (control as NSObject).rx.deallocated.subscribe(onNext: { _ in
                deallocated = true
            })

            control = nil
        }


        // this code is here to flush any events that were scheduled to
        // run on main loop
        DispatchQueue.main.async {
            let runLoop = CFRunLoopGetCurrent()
            CFRunLoopStop(runLoop)
        }
        let runLoop = CFRunLoopGetCurrent()
        CFRunLoopWakeUp(runLoop)
        CFRunLoopRun()

        XCTAssertTrue(deallocated, "not deallocated", file: file, line: line)
        XCTAssertTrue(completed, "not completed", file: file, line: line)
        XCTAssertTrue(comparer(initialValue, lastReturnedPropertyValue), "last property value (\(String(describing: lastReturnedPropertyValue))) does not match initial value (\(initialValue))", file: file, line: line)
    }
}
