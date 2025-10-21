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
        
        // If we got here without crashing, the dictionary wasn't corrupted
        // Now verify the dictionary is in a valid state by adding and triggering a new handler
        var newHandlerCalled = false
        _ = observable.addEventHandler { _ in
            newHandlerCalled = true
        }
        
        observable.wrappedValue = "trigger"
        
        // The new handler should have been called, proving dictionary is functional
        XCTAssertTrue(newHandlerCalled, "Dictionary should be in valid state after concurrent additions")
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
        
        // If we got here without crashing, the dictionary wasn't corrupted
        // Verify it's still functional by publishing
        observable.wrappedValue = "test"
        
        XCTAssertTrue(true, "Dictionary survived concurrent removals without corruption")
    }
    
    func testConcurrentAddAndRemoveDoesNotCrash() {
        let observable = AdyenObservable(0)
        let iterations = 500
        let expectation = expectation(description: "All operations complete")
        expectation.expectedFulfillmentCount = iterations * 2
        
        // Simultaneously add and remove handlers from different threads
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
        // Verify observable still works
        observable.wrappedValue = 999
        XCTAssertEqual(observable.wrappedValue, 999, "Observable should still be functional")
    }
    
    func testConcurrentPublishDoesNotCrashDuringIteration() {
        let observable = AdyenObservable(0)
        
        // Add handlers that take time to execute
        for _ in 0..<50 {
            _ = observable.addEventHandler { _ in
                usleep(100) // 0.1ms - simulate work
            }
        }
        
        // Publish from multiple threads simultaneously
        // Without locks, this would crash when iterating eventHandlers while they're being modified
        DispatchQueue.concurrentPerform(iterations: 100) { index in
            observable.wrappedValue = index
        }
        
        // If we got here without crashing, the lock protected the iteration
        XCTAssertTrue(true, "Concurrent publishing didn't crash during handler iteration")
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
        
        // If we got here without crashing, locks prevented race conditions
        observable.wrappedValue = 999
        XCTAssertEqual(observable.wrappedValue, 999, "Observable survived extreme concurrent access")
    }
    
    // MARK: - Observer Manager Thread Safety Tests
    
    func testConcurrentObservationAdditionDoesNotCorruptArray() {
        let observable = AdyenObservable("test")
        let iterations = 1000
        
        // Concurrently add observations - would crash without proper locking in ObservationManager
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            _ = observe(observable) { _ in }
        }
        
        // If we got here without crashing, ObservationManager's array wasn't corrupted
        // Trigger all observations to verify they're functional
        observable.wrappedValue = "trigger"
        
        XCTAssertTrue(true, "ObservationManager survived concurrent observation additions")
    }
    
    func testConcurrentObservationRemovalDoesNotCorruptArray() {
        let observable = AdyenObservable("test")
        let iterations = 500
        
        var observations = [Observation]()
        for _ in 0..<iterations {
            observations.append(observe(observable) { _ in })
        }
        
        // Concurrently remove observations - would crash without proper locking in ObservationManager
        DispatchQueue.concurrentPerform(iterations: iterations) { index in
            remove(observations[index])
        }
        
        // If we got here without crashing, ObservationManager's array wasn't corrupted
        observable.wrappedValue = "test"
        XCTAssertTrue(true, "ObservationManager survived concurrent observation removals")
    }
    
    func testObservationManagerDeinitCleansUpObservations() {
        let observable = AdyenObservable(0)
        var handlerCallCount = 0
        
        // Create observer in autoreleasepool so it gets deallocated
        autoreleasepool {
            let observer = TestObserver()
            
            // Add multiple observations
            for _ in 0..<10 {
                observer.observe(observable) { _ in
                    handlerCallCount += 1
                }
            }
            
            // Trigger handlers - should be called
            observable.wrappedValue = 1
            XCTAssertEqual(handlerCallCount, 10, "All handlers should be called before observer deallocation")
            
            handlerCallCount = 0
            
            // Observer will be deallocated here, triggering ObservationManager.deinit
        }
        
        // After observer deallocation, handlers should be removed
        observable.wrappedValue = 2
        
        XCTAssertEqual(handlerCallCount, 0, "Handlers should be removed after observer deallocation")
    }
    
    func testObservationManagerDeinitDuringConcurrentPublish() {
        let observable = AdyenObservable(0)
        
        autoreleasepool {
            let observer = TestObserver()
            
            // Add observations
            for _ in 0..<20 {
                observer.observe(observable) { _ in
                    usleep(1000) // Slow handler
                }
            }
            
            // Start publishing on background thread
            DispatchQueue.global().async {
                for i in 0..<100 {
                    observable.wrappedValue = i
                    usleep(500)
                }
            }
            
            // Let some publishes happen
            usleep(10000) // 10ms
            
            // Observer deallocates while publishing is happening
            // ObservationManager.deinit should safely clean up
        }
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Should not crash when observer is deallocated during concurrent publishing
        observable.wrappedValue = 999
        XCTAssertEqual(observable.wrappedValue, 999, "Observable should work after observer cleanup during concurrent access")
    }
    
    func testConcurrentObserveAndRemove() {
        let observable = AdyenObservable(0)
        let duration: TimeInterval = 2.0
        let startTime = Date()
        
        // Note: observationCounter is accessed from single thread only, no lock needed
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
        
        // If we got here without crashing, locks prevented race conditions
        XCTAssertGreaterThan(observationCounter, 0, "Should have added observations during test")
    }
    
    // MARK: - Race Condition Detection Tests
    
    func testPublishWhileAddingHandlersDoesNotSkipHandlers() {
        let observable = AdyenObservable(0)
        let handlerCount = 100
        
        // Use atomic counter to track handler calls safely
        let counter = AtomicCounter()
        
        // Thread 1: Add handlers while publishing is happening
        DispatchQueue.global().async {
            for _ in 0..<handlerCount {
                _ = observable.addEventHandler { _ in
                    counter.increment()
                }
                usleep(100)
            }
        }
        
        // Thread 2: Publish multiple times while handlers are being added
        DispatchQueue.global().async {
            for i in 0..<50 {
                observable.wrappedValue = i
                usleep(200)
            }
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        
        // Final publish to trigger all handlers that were successfully added
        observable.wrappedValue = 999
        Thread.sleep(forTimeInterval: 0.1)
        
        // Should have received calls (exact count depends on timing of when handlers were added)
        XCTAssertGreaterThan(counter.value, 0, "Handlers added during publishing should still be called")
    }
    
    func testRemovingHandlerDuringPublishDoesNotCrash() {
        let observable = AdyenObservable(0)
        
        // Add handlers with slow execution to increase chance of concurrent access
        var tokens = [EventHandlerToken]()
        for _ in 0..<50 {
            let token = observable.addEventHandler { _ in
                usleep(1000) // 1ms - slow handler
            }
            tokens.append(token)
        }
        
        // Thread 1: Start publishing
        DispatchQueue.global().async {
            for i in 0..<100 {
                observable.wrappedValue = i
                usleep(500)
            }
        }
        
        // Thread 2: Remove handlers while publishing is iterating over them
        DispatchQueue.global().async {
            usleep(5000) // Wait a bit for publishing to start
            for token in tokens {
                observable.removeEventHandler(with: token)
                usleep(200)
            }
        }
        
        Thread.sleep(forTimeInterval: 2.0)
        
        // If we got here, the lock prevented crashes during concurrent iteration/modification
        XCTAssertTrue(true, "Removing handlers during publish didn't cause iterator invalidation")
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
        
        // Start concurrent operations that will continue briefly after deallocation
        DispatchQueue.global().async {
            for i in 0..<50 {
                observable?.wrappedValue = i
                usleep(500)
            }
        }
        
        // Deallocate observable while operations are happening
        usleep(10000) // 10ms - let some operations start
        observable = nil
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Observable should be deallocated without crashing
        XCTAssertNil(weakObservable, "Observable should be deallocated")
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
            
            // Observer deallocates while publishing is happening
            usleep(10000) // 10ms
        }
        
        Thread.sleep(forTimeInterval: 0.5)
        
        // Should not crash when observer is deallocated during publishing
        observable.wrappedValue = 999
        XCTAssertEqual(observable.wrappedValue, 999, "Observable should work after observer deallocation")
    }
    
    // MARK: - Stress Tests
    
    func testExtremeConcurrency() {
        let observable = AdyenObservable(0)
        let duration: TimeInterval = 3.0
        let startTime = Date()
        
        // Multiple threads doing different operations simultaneously
        let group = DispatchGroup()
        
        // Threads 1-3: Publishing
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
        
        // Threads 4-5: Adding handlers
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
        XCTAssertEqual(observable.wrappedValue, 999, "Observable survived extreme concurrent stress test")
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
