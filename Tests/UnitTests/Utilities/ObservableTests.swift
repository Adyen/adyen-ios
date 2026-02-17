//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class ObservableTests: XCTestCase, AdyenObserver {
    
    func testBasicObservation() {
        var latestValue: Bool?
        
        let observable = AdyenObservable(false)
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
        let observable = AdyenObservable("")
        
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
        let observable = AdyenObservable("")
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
        
        // Auto release pool should have been executed.
        XCTAssertEqual(observable.wrappedValue, "Test 1")
        
        // Owner should have been released.
        XCTAssertNil(observer)
        
        // Event handler is not invoked for new values.
        observable.wrappedValue = "Test 2"
        XCTAssertEqual(count, 1)
    }
    
    func testSettingEqualValue() {
        let observable = AdyenObservable("")
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

    func testBindingProperty() {
        let emitter = TestObserver()
        let receiver = TestObserver()
        bind(emitter.$observableString, to: receiver, at: \.stringValue)
        bind(emitter.$observableString, to: receiver, at: \.optionalStringValue)
        bind(emitter.$observableString, to: receiver, at: \.observableObject.stringValue)

        emitter.observableString = "Hello World"
        XCTAssertEqual(emitter.observableString, receiver.stringValue)
        XCTAssertEqual(emitter.observableString, receiver.optionalStringValue)
        XCTAssertEqual(emitter.observableString, receiver.observableObject.stringValue)
    }

    func testBindingObject() {
        let emitter = TestObserver()
        let receiver = TestObserver()
        bind(emitter.$observableObject, at: \.stringValue, to: receiver, at: \.stringValue)
        bind(emitter.$observableObject, at: \.stringValue, to: receiver, at: \.optionalStringValue)
        bind(emitter.$observableObject, at: \.stringValue, to: receiver, at: \.observableObject.stringValue)

        emitter.observableObject.stringValue = "Hello World"
        XCTAssertEqual(emitter.observableObject.stringValue, receiver.stringValue)
        XCTAssertEqual(emitter.observableObject.stringValue, receiver.optionalStringValue)
        XCTAssertEqual(emitter.observableObject.stringValue, receiver.observableObject.stringValue)
    }

    func testBindingTransformation() {
        let emitter = TestObserver()
        let receiver = TestObserver()
        XCTAssertFalse(receiver.observableObject.boolValue)
        bind(emitter.$observableString, to: receiver, at: \.observableObject.boolValue, with: { $0.contains("Hello") })

        emitter.observableString = "Hello World"
        XCTAssertTrue(receiver.observableObject.boolValue)
    }

    // MARK: - Event Handler Token Tests

    func test_addEventHandler_withoutRetainedToken_shouldPersistIndefinitely() {
        let sut = makeObservable(initialValue: 0)
        var handlerCallCount = 0
        
        // When: Add handler without retaining token
        addHandler(to: sut) { handlerCallCount += 1 }
        
        // Then: Handler should be called for each value change
        setValue(sut, to: 1)
        XCTAssertEqual(handlerCallCount, 1, "Handler should be called even without retained token")
        
        setValue(sut, to: 2)
        XCTAssertEqual(handlerCallCount, 2, "Handler should continue to be called")
        
        // The handler remains active for the lifetime of the observable
        // This demonstrates potential memory accumulation if tokens aren't retained
    }
    
    func test_addEventHandler_withRetainedToken_shouldAllowManualRemoval() {
        let sut = makeObservable(initialValue: 0)
        var handlerCallCount = 0
        
        // When: Add handler and retain the token
        let token = addHandler(to: sut) { handlerCallCount += 1 }
        
        setValue(sut, to: 1)
        XCTAssertEqual(handlerCallCount, 1, "Handler should be called")
        
        // When: Explicitly remove the handler using the token
        removeHandler(from: sut, with: token)
        
        // Then: Handler should no longer be called after removal
        setValue(sut, to: 2)
        XCTAssertEqual(handlerCallCount, 1, "Handler should not be called after removal")
    }
    
    func test_addEventHandler_multipleHandlersWithoutTokens_shouldAllPersist() {
        let sut = makeObservable(initialValue: 0)
        var handler1CallCount = 0
        var handler2CallCount = 0
        var handler3CallCount = 0
        
        // When: Add multiple handlers without retaining tokens
        addHandler(to: sut) { handler1CallCount += 1 }
        addHandler(to: sut) { handler2CallCount += 1 }
        addHandler(to: sut) { handler3CallCount += 1 }
        
        // Then: All handlers should be called for each value change
        setValue(sut, to: 1)
        XCTAssertEqual(handler1CallCount, 1)
        XCTAssertEqual(handler2CallCount, 1)
        XCTAssertEqual(handler3CallCount, 1)
        
        // All handlers accumulate in memory without cleanup mechanism
        setValue(sut, to: 2)
        XCTAssertEqual(handler1CallCount, 2)
        XCTAssertEqual(handler2CallCount, 2)
        XCTAssertEqual(handler3CallCount, 2)
        
        // This demonstrates that handlers without retained tokens remain active
        // and can lead to memory accumulation over time
    }
    
    // MARK: - Helper Methods
    
    private func makeObservable(initialValue: Int) -> AdyenObservable<Int> {
        AdyenObservable(initialValue)
    }
    
    @discardableResult
    private func addHandler(
        to observable: AdyenObservable<Int>,
        eventHandler: @escaping () -> Void
    ) -> EventHandlerToken {
        observable.addEventHandler { _ in eventHandler() }
    }
    
    private func removeHandler(
        from observable: AdyenObservable<Int>,
        with token: EventHandlerToken
    ) {
        observable.removeEventHandler(with: token)
    }
    
    private func setValue(_ observable: AdyenObservable<Int>, to value: Int) {
        observable.wrappedValue = value
    }

    class TestObserver: AdyenObserver {
        var stringValue: String = ""
        var optionalStringValue: String?

        @AdyenObservable("") var observableString: String
        @AdyenObservable(OtherObject()) var observableObject: OtherObject

    }

    struct OtherObject: Equatable {
        var stringValue: String = ""
        var boolValue: Bool = false
    }
}
