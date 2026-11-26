//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest

extension XCTestCase {
    /// Waits for a specified amount of time
    ///
    /// Spins the current run loop in short slices until the deadline is reached,
    /// so main-queue work keeps flowing even when called from `@MainActor` tests.
    ///
    /// - Parameters:
    ///   - interval: the dispach time interval to wait for
    func wait(for interval: DispatchTimeInterval) {
        let deadline = Date().addingTimeInterval(interval.timeInterval)
        
        while Date() < deadline {
            if Thread.isMainThread {
                RunLoop.current.run(until: Date().addingTimeInterval(0.01))
            } else {
                Thread.sleep(forTimeInterval: 0.01)
            }
        }
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
        timeout: TimeInterval = 60,
        retryInterval: DispatchTimeInterval = .seconds(1),
        message: String? = nil,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let thresholdDate = Date().addingTimeInterval(timeout)
        
        var isMatchingExpectation = expectation()
        
        while thresholdDate.timeIntervalSinceNow > 0, !isMatchingExpectation {
            wait(for: retryInterval)
            isMatchingExpectation = expectation()
        }
        
        XCTAssertTrue(isMatchingExpectation, message ?? "Expectation should be met before timeout \(timeout)s", file: file, line: line)
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
        file: StaticString = #file,
        line: Int = #line
    ) {
        wait(
            until: { target[keyPath: keyPath] == expectedValue },
            timeout: timeout,
            message: "Value of \(keyPath) (\(target[keyPath: keyPath])) should become \(String(describing: expectedValue)) within \(timeout)s [line:\(line)]"
        )
    }
}

private extension DispatchTimeInterval {
    /// The interval expressed in seconds.
    /// `.never` resolves to `0` since waiting forever is not meaningful for a synchronous test helper.
    var timeInterval: TimeInterval {
        switch self {
        case let .seconds(value):
            TimeInterval(value)
        case let .milliseconds(value):
            TimeInterval(value) / 1000
        case let .microseconds(value):
            TimeInterval(value) / 1000000
        case let .nanoseconds(value):
            TimeInterval(value) / 1000000000
        case .never:
            0
        @unknown default:
            0
        }
    }
}
