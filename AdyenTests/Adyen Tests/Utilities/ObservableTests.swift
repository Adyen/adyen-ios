//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class ObservableTests: XCTestCase, Observer {
    
    func testBasicObservation() {
        var latestValue: Bool?
        
        let observable = Observable(false)
        let observation = observe(observable) { newValue in
            latestValue = newValue
        }
        
        // The event handler should not be called for the initial value.
        XCTAssertNil(latestValue)
        
        // The event handler should be called for new values.
        observable.wrappedValue = true
        XCTAssertEqual(latestValue, true)
        
        // Remove the observation.
        remove(observation)
        
        // The event handler should NOT be called.
        observable.wrappedValue = false
        XCTAssertEqual(latestValue, true)
    }
    
    func testMultipleObservations() {
        let observable = Observable("")
        
        var observation1Count = 0
        observe(observable) { _ in
            observation1Count += 1
        }
        
        var observation2Count = 0
        let observation2 = observe(observable) { _ in
            observation2Count += 1
        }
        
        // Both handlers should not have been called yet.
        XCTAssertEqual(observation1Count, 0)
        XCTAssertEqual(observation2Count, 0)
        
        observable.wrappedValue = "Hello World"
        
        // Both handlers should have been called.
        XCTAssertEqual(observation1Count, 1)
        XCTAssertEqual(observation2Count, 1)
        
        remove(observation2)
        
        observable.wrappedValue = "Goodbye World"
        
        // Only the first handler should have been called.
        XCTAssertEqual(observation1Count, 2)
        XCTAssertEqual(observation2Count, 1)
    }
    
    func testAutomaticObservationRemoval() {
        let observable = Observable("")
        weak var observer: TestObserver?
        var count = 0
        
        autoreleasepool {
            let temporaryObserver = TestObserver()
            observer = temporaryObserver
            
            temporaryObserver.observe(observable) { _ in
                count += 1
            }
            
            // Counter should be functioning.
            observable.wrappedValue = "Test 1"
            XCTAssertEqual(count, 1)
        }
        
        // Autoreleasepool should have been executed.
        XCTAssertEqual(observable.wrappedValue, "Test 1")
        
        // Owner should have been released.
        XCTAssertNil(observer)
        
        // Event handler is not invoked for new values.
        observable.wrappedValue = "Test 2"
        XCTAssertEqual(count, 1)
    }
    
    func testSettingEqualValue() {
        let observable = Observable("")
        var count = 0
        
        observe(observable) { _ in
            count += 1
        }
        
        observable.wrappedValue = "Hello World"
        observable.wrappedValue = "Hello World"
        observable.wrappedValue = "Goodbye World"
        observable.wrappedValue = "Hello World"
        observable.wrappedValue = "Hello World"
        observable.wrappedValue = "Goodbye World"
        observable.wrappedValue = "Goodbye World"
        
        // The handler should only be called for unique values.
        XCTAssertEqual(count, 4)
    }
    
    class TestObserver: Observer {}
    
}
