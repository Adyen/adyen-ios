//
//  XCTestCaseExtensions.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 12/1/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import UIKit
import XCTest

extension XCTestCase {
    func wait(for interval: DispatchTimeInterval) {
        let dummyExpectation = XCTestExpectation(description: "wait for a few seconds.")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
            dummyExpectation.fulfill()
        }

        wait(for: [dummyExpectation], timeout: 100)
    }
    
    func waitFor(predicate: @escaping () -> Bool) {
        let dummyExpectation = XCTNSPredicateExpectation(predicate: NSPredicate(block: { _, _ in
            predicate()
        }), object: nil)

        wait(for: [dummyExpectation], timeout: 100)
    }
    
    func wait<Value: Equatable, Target: AnyObject>(
        until target: Target,
        at keyPath: KeyPath<Target, Value>,
        is expectedValue: Value,
        timeout: TimeInterval
    ) {
        wait(
            until: { target[keyPath: keyPath] == expectedValue },
            timeout: timeout,
            message: "Value of \(String(describing: Target.self)) (\(target[keyPath: keyPath])) should become \(String(describing: expectedValue)) within \(timeout)s"
        )
    }
    
    func wait(
        until expectation: () -> Bool,
        timeout: TimeInterval,
        message: String? = nil
    ) {
        var timeLeft = Int(timeout * 1000)
        let incrementInterval = 10
        
        while timeLeft > 0 && expectation() == false {
            wait(for: .milliseconds(incrementInterval))
            timeLeft -= incrementInterval
        }
        
        XCTAssertTrue(expectation(), message ?? "Expectation was not met before timeout \(timeout)")
    }
}
