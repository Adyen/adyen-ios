//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit
import XCTest

extension XCTestCase {
            
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
