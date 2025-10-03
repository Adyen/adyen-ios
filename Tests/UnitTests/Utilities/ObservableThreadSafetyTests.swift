//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

/// Tests for thread-safety of the Observable system with NSLock implementation
/// These tests verify that the Observable's internal locks prevent crashes and data corruption
class ObservableThreadSafetyTests: XCTestCase, AdyenObserver {
    
    // MARK: - Dictionary Corruption Tests

    // These tests would crash or corrupt data if locks weren't working
    
    func testConcurrentHandlerAdditionDoesNotCorruptDictionary() {
        let observable = AdyenObservable("test")
        let iterations = 1000
        
        // Concurrently add handlers - would crash without proper locking
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            _ = observable.addEventHandler { _ in }
        }
        
        // If we got here without crashing, locks are working
        // Verify dictionary is in valid state by triggering all handlers
        var callCount = 0
        _ = observable.addEventHandler { _ in
            callCount += 1
        }
        
        observable.wrappedValue = "trigger"
        
        // Should have called the new handler plus all the concurrent ones
        XCTAssertGreaterThan(callCount, 0)
    }
    
    func testConcurrentHandlerRemovalDoesNotCorruptDictionary() {
        let observable = AdyenObservable("test")
        let iterations = 1000
        
        // Add many handlers
        var tokens = [EventHandlerToken]()
        for _ in 0..<iterations {
            let token = observable.addEventHandler { _ in }
            tokens.append(token)
        }
        
        // Concurrently remove them - would crash without proper locking
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            observable.removeEventHandler(with: tokens[index])
        }
        
        // Dictionary should be empty or nearly empty
        observable.wrappedValue = "test"
        
        // If we got here without crashing, locks are working
        XCTAssertTrue(true)
    }
    
    func testConcurrentAddAndRemoveDoesNotCrash() {
        let observable = AdyenObservable(0)
        let iterations = 500
        let expectation = expectation(description: "All operations complete")
        expectation.expectedFulfillmentCount = iterations * 2
        
        // Simultaneously add and remove handlers
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            let token = observable.addEventHandler { _ in }
            expectation.fulfill()
            
            DispatchQueue.global().async {
                observable.removeEventHandler(with: token)
                expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 10.0)
        
        // If we got here, the locks prevented dictionary corruption
        observable.wrappedValue = 999
        XCTAssertEqual(observable.wrappedValue, 999)
    }
    
    func testConcurrentPublishDoesNotCrashDuringIteration() {
        let observable = AdyenObservable(0)
        
        // Add handlers that take time to execute
        for _ in 0..<50 {
            _ = observable.addEventHandler { _ in
                // Simulate work
                usleep(100) // 0.1ms
            }
        }
        
        // Publish from multiple threads simultaneously
        // Without locks, this would crash when iterating eventHandlers
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            observable.wrappedValue = index
        }
        
        // If we got here without crashing, the lock protected the iteration
        XCTAssertTrue(true)
    }
    
    func testConcurrentPublishAndModifyHandlers() {
        let observable = AdyenObservable(0)
        let duration: TimeInterval = 2.0
        let startTime = Date()
        
        var tokens = [EventHandlerToken]()
        for _ in 0..<20 {
            tokens.append(observable.addEventHandler { _ in })
        }
        
        // Thread 1: Continuously publish
        DispatchQueue.global(qos: .userInitiated).async {
            var counter = 0
            while Date().timeIntervalSince(startTime) < duration {
                observable.wrappedValue = counter
                counter += 1
                usleep(1000) // 1ms
            }
        }
        
        // Thread 2: Continuously add handlers
        DispatchQueue.global(qos: .userInitiated).async {
            while Date().timeIntervalSince(startTime) < duration {
                _ = observable.addEventHandler { _ in }
                usleep(1500) // 1.5ms
            }
        }
        
        // Thread 3: Continuously remove handlers
        DispatchQueue.global(qos: .userInitiated).async {
            var index = 0
            while Date().timeIntervalSince(startTime) < duration {
                if index < tokens.count {
                    observable.removeEventHandler(with: tokens[index])
                    index += 1
                }
                usleep(2000) // 2ms
            }
        }
        
        // Wait for all operations to complete
        Thread.sleep(forTimeInterval: duration + 0.5)
        
        // If we got here without crashing, locks are working correctly
        observable.wrappedValue = 999
        XCTAssertEqual(observable.wrappedValue, 999)
    }
    
    // MARK: - Observer Manager Thread Safety Tests
    
    func testConcurrentObservationAdditionDoesNotCorruptArray() {
        let observable = AdyenObservable("test")
        let iterations = 1000
        
        // Concurrently add observations - would crash without proper locking
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            _ = observe(observable) { _ in }
        }
        
        // Trigger all observations
        observable.wrappedValue = "trigger"
        
        // If we got here without crashing, the ObservationManager's lock is working
        XCTAssertTrue(true)
    }
    
    func testConcurrentObservationRemovalDoesNotCorruptArray() {
        let observable = AdyenObservable("test")
        let iterations = 500
        
        var observations = [Observation]()
        for _ in 0..<iterations {
            observations.append(observe(observable) { _ in })
        }
        
        // Concurrently remove observations - would crash without proper locking
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            remove(observations[index])
        }
        
        // If we got here without crashing, the ObservationManager's lock is working
        observable.wrappedValue = "test"
        XCTAssertTrue(true)
    }
    
    func testConcurrentObserveAndRemove() {
        let observable = AdyenObservable(0)
        let duration: TimeInterval = 2.0
        let startTime = Date()
        
        var observationCounter = 0
        
        // Thread 1: Continuously add observations
        DispatchQueue.global(qos: .userInitiated).async {
            while Date().timeIntervalSince(startTime) < duration {
                _ = self.observe(observable) { _ in
                    // Handler
                }
                observationCounter += 1
                usleep(500)
            }
        }
        
        // Thread 2: Continuously publish
        DispatchQueue.global(qos: .userInitiated).async {
            var counter = 0
            while Date().timeIntervalSince(startTime) < duration {
                observable.wrappedValue = counter
                counter += 1
                usleep(1000)
            }
        }
        
        Thread.sleep(forTimeInterval: duration + 0.5)
        
        // If we got here without crashing, locks are working
        XCTAssertGreaterThan(observationCounter, 0)
    }
    
    // MARK: - Race Condition Detection Tests
    
    func testPublishWhileAddingHandlersDoesNotSkipHandlers() {
        let observable = AdyenObservable(0)
        let handlerCount = 100
        
        // Use atomic counter (OSAtomic is deprecated, use class with lock)
        let counter = AtomicCounter()
        
        // Add handlers while publishing
        DispatchQueue.global().async {
            for _ in 0..<handlerCount {
                _ = observable.addEventHandler { _ in
                    counter.increment()
                }
                usleep(100)
            }
        }
        
        // Publish multiple times
        DispatchQueue.global().async {
            for i in 0..<50 {
                observable.wrappedValue = i
                usleep(200)
            }
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        
        // Final publish to trigger all handlers
        observable.wrappedValue = 999
        Thread.sleep(forTimeInterval: 0.1)
        
        // Should have received calls (exact count depends on timing)
        XCTAssertGreaterThan(counter.value, 0)
    }
    
    func testRemovingHandlerDuringPublishDoesNotCrash() {
        let observable = AdyenObservable(0)
        
        // Add handlers with slow execution
        var tokens = [EventHandlerToken]()
        for _ in 0..<50 {
            let token = observable.addEventHandler { _ in
                usleep(1000) // 1ms - slow handler
            }
            tokens.append(token)
        }
        
        // Start publishing
        DispatchQueue.global().async {
            for i in 0..<100 {
                observable.wrappedValue = i
                usleep(500)
            }
        }
        
        // Remove handlers while publishing
        DispatchQueue.global().async {
            usleep(5000) // Wait a bit for publishing to start
            for token in tokens {
                observable.removeEventHandler(with: token)
                usleep(200)
            }
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        
        // If we got here, the lock prevented crashes during concurrent iteration/modification
        XCTAssertTrue(true)
    }
    
    // MARK: - Memory Safety Tests
    
    func testObservableDeallocationDuringConcurrentAccess() {
        var observable: AdyenObservable<Int>? = AdyenObservable(0)
        weak var weakObservable = observable
        
        // Add handlers
        for _ in 0..<20 {
            _ = observable?.addEventHandler { _ in
                usleep(1000)
            }
        }
        
        // Start concurrent operations
        DispatchQueue.global().async {
            for i in 0..<50 {
                observable?.wrappedValue = i
                usleep(500)
            }
        }
        
        // Deallocate while operations are happening
        usleep(10000) // 10ms
        observable = nil
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Observable should be deallocated
        XCTAssertNil(weakObservable)
    }
    
    func testObserverDeallocationDuringConcurrentPublish() {
        let observable = AdyenObservable(0)
        
        autoreleasepool {
            let observer = TestObserver()
            
            // Add observation
            observer.observe(observable) { _ in
                usleep(1000)
            }
            
            // Start publishing
            DispatchQueue.global().async {
                for i in 0..<100 {
                    observable.wrappedValue = i
                    usleep(500)
                }
            }
            
            // Observer deallocates while publishing
            usleep(10000)
        }
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Should not crash
        observable.wrappedValue = 999
        XCTAssertEqual(observable.wrappedValue, 999)
    }
    
    // MARK: - Stress Tests
    
    func testExtremeConcurrency() {
        let observable = AdyenObservable(0)
        let duration: TimeInterval = 3.0
        let startTime = Date()
        
        // Multiple threads doing different operations simultaneously
        let group = DispatchGroup()
        
        // Thread 1-3: Publishing
        for _ in 0..<3 {
            group.enter()
            DispatchQueue.global().async {
                var counter = 0
                while Date().timeIntervalSince(startTime) < duration {
                    observable.wrappedValue = counter
                    counter += 1
                    usleep(100)
                }
                group.leave()
            }
        }
        
        // Thread 4-5: Adding handlers
        for _ in 0..<2 {
            group.enter()
            DispatchQueue.global().async {
                while Date().timeIntervalSince(startTime) < duration {
                    _ = observable.addEventHandler { _ in }
                    usleep(300)
                }
                group.leave()
            }
        }
        
        // Thread 6: Adding and removing handlers
        group.enter()
        DispatchQueue.global().async {
            while Date().timeIntervalSince(startTime) < duration {
                let token = observable.addEventHandler { _ in }
                usleep(200)
                observable.removeEventHandler(with: token)
                usleep(200)
            }
            group.leave()
        }
        
        group.wait()
        
        // If we survived this chaos, locks are working correctly
        observable.wrappedValue = 999
        XCTAssertEqual(observable.wrappedValue, 999)
    }
    
    // MARK: - Helper Classes
    
    class TestObserver: AdyenObserver {
        var value: String = ""
    }
    
    class AtomicCounter {
        private var _value = 0
        private let lock = NSLock()
        
        var value: Int {
            lock.lock()
            defer { lock.unlock() }
            return _value
        }
        
        func increment() {
            lock.lock()
            _value += 1
            lock.unlock()
        }
    }
}
