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
    
    // MARK: - Wait For
    
    func wait(for interval: DispatchTimeInterval) {
        let dummyExpectation = XCTestExpectation(description: "wait for a few seconds.")

        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
            dummyExpectation.fulfill()
        }

        wait(for: [dummyExpectation], timeout: 100)
    }
    
    // MARK: - Wait Until
    
    func wait<Value: Equatable, Target: AnyObject>(
        until target: Target,
        at keyPath: KeyPath<Target, Value>,
        is expectedValue: Value,
        timeout: TimeInterval = 1
    ) {
        wait(
            until: { target[keyPath: keyPath] == expectedValue },
            timeout: timeout,
            message: "Value of \(String(describing: Target.self)) (\(target[keyPath: keyPath])) should become \(String(describing: expectedValue)) within \(timeout)s"
        )
    }
    
    func wait(
        until expectation: () -> Bool,
        timeout: TimeInterval = 1,
        message: String? = nil
    ) {
        var timeLeft = Int(timeout * 1000)
        let incrementInterval = 10
        
        while timeLeft > 0 && expectation() == false {
            wait(for: .milliseconds(incrementInterval))
            timeLeft -= incrementInterval
        }
        
        XCTAssertTrue(expectation(), message ?? "Expectation was not met before timeout \(timeout)s")
    }
    
    // MARK: - Wait For/Until UIViewController
    
    @discardableResult
    func waitForViewController<T: UIViewController>(
        ofType: T.Type,
        toBecomeChildOf viewController: UIViewController,
        timeout: TimeInterval = 1
    ) throws -> T {
        
        wait(
            until: { viewController.firstChild(of: T.self) != nil },
            timeout: timeout,
            message: "\(String(describing: T.self)) did not appear on \(String(describing: viewController.self)) before timeout \(timeout)s"
        )
        
        return try XCTUnwrap(viewController.firstChild(of: T.self))
    }
    
    @discardableResult
    func waitUntilTopPresenter<T: UIViewController>(
        isOfType: T.Type,
        timeout: TimeInterval = 1
    ) throws -> T {
        
        wait(
            until: { (try? UIViewController.topPresenter() is T) ?? false },
            timeout: timeout,
            message: "\(String(describing: T.self)) did not become top presenter before timeout \(timeout)s"
        )
        
        return try XCTUnwrap(UIViewController.topPresenter() as? T)
    }
}
