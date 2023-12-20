//
//  XCTestCase+Wait.swift
//  AdyenUIKitTests
//
//  Created by Mohamed Eldoheiri on 12/1/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import UIKit
import XCTest

extension XCTestCase {
    
    /// Waits for a specified amount of time
    ///
    /// - Parameters:
    ///   - interval: the dispach time interval to wait for
    func wait(for interval: DispatchTimeInterval) {
        let dummyExpectation = XCTestExpectation(description: "wait for some time.")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
            dummyExpectation.fulfill()
        }

        wait(for: [dummyExpectation], timeout: 1000)
    }
    
    /// Waits until  a certain condition is met
    ///
    /// Instead of waiting for a specific amount of time it polls if the expecation is returning true in time intervals of 10ms until the timeout is reached.
    /// Use it whenever a value change is not guaranteed to be instant or happening after a short amount of time.
    ///
    /// - Parameters:
    ///   - expectation: the condition that is waited on
    ///   - timeout: the maximum time (in seconds)  to wait.
    ///   - retryInterval: the waiting time inbetween retries
    ///   - message: an optional message on failure
    func wait(
        until expectation: () -> Bool,
        timeout: TimeInterval = 120,
        retryInterval: DispatchTimeInterval = .seconds(1),
        message: String? = nil
    ) {
        let thresholdDate = Date().addingTimeInterval(timeout)
        
        var isMatchingExpectation = expectation()
        
        while thresholdDate.timeIntervalSinceNow > 0, !isMatchingExpectation {
            wait(for: retryInterval)
            isMatchingExpectation = expectation()
        }
        
        XCTAssertTrue(isMatchingExpectation, message ?? "Expectation should be met before timeout \(timeout)s")
    }
    
    /// Waits until  a keyPath of a target matches an expected value
    ///
    /// Instead of waiting for a specific amount of time it polls if the expecation is returning true in time intervals of 10ms until the timeout is reached.
    /// Use it whenever a value change is not guaranteed to be instant or happening after a short amount of time.
    ///
    /// - Parameters:
    ///   - target: the target to observe
    ///   - keyPath: the keyPath to check
    ///   - expectedValue: the value to check against
    ///   - timeout: the maximum time (in seconds)  to wait.
    func wait<Value: Equatable, Target: AnyObject>(
        until target: Target,
        at keyPath: KeyPath<Target, Value>,
        is expectedValue: Value,
        timeout: TimeInterval = 120,
        line: Int = #line
    ) {
        wait(
            until: { target[keyPath: keyPath] == expectedValue },
            timeout: timeout,
            message: "Value of \(keyPath) (\(target[keyPath: keyPath])) should become \(String(describing: expectedValue)) within \(timeout)s [line:\(line)]"
        )
    }
    
    /// Waits for a viewController of a certain type to become a child of another viewController
    ///
    /// Instead of waiting for a specific amount of time it polls if the expecation is returning true in time intervals of 10ms until the timeout is reached.
    /// Use it whenever a value change is not guaranteed to be instant or happening after a short amount of time.
    ///
    /// - Parameters:
    ///   - ofType: the type of the expected child viewController
    ///   - viewController: the parent viewController
    ///   - timeout: the maximum time (in seconds)  to wait.
    @discardableResult
    func waitForViewController<T: UIViewController>(
        ofType: T.Type,
        toBecomeChildOf viewController: UIViewController,
        timeout: TimeInterval = 60
    ) throws -> T {
        
        wait(
            until: { viewController.firstChild(of: T.self) != nil },
            timeout: timeout,
            message: "\(String(describing: T.self)) should appear on \(String(describing: viewController.self)) before timeout \(timeout)s"
        )
        
        return try XCTUnwrap(viewController.firstChild(of: T.self))
    }
    
    /// Waits for a viewController of a certain type to become a child of another viewController
    ///
    /// Instead of waiting for a specific amount of time it polls if the expecation is returning true in time intervals of 10ms until the timeout is reached.
    /// Use it whenever a value change is not guaranteed to be instant or happening after a short amount of time.
    ///
    /// - Parameters:
    ///   - ofType: the type of the expected child viewController
    ///   - viewController: the parent viewController
    ///   - timeout: the maximum time (in seconds)  to wait.
    @discardableResult
    func waitUntilTopPresenter<T: UIViewController>(
        isOfType: T.Type,
        timeout: TimeInterval = 60
    ) throws -> T {
        
        wait(
            until: { (try? UIViewController.topPresenter() is T) ?? false },
            timeout: timeout,
            message: "\(String(describing: T.self)) should become top presenter before timeout \(timeout)s"
        )
        
        return try XCTUnwrap(UIViewController.topPresenter() as? T)
    }
}
