//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class KeyboardObserverTests: XCTestCase {
    
    class DummyAdyenObserver: AdyenObserver {}
    var adyenObserver: DummyAdyenObserver?
    
    func testKeyboardNotificationHandling() {
        
        let keyboardObserver = KeyboardObserver()
        var expectedRects: [CGRect] = [
            .init(origin: .zero, size: .init(width: 100, height: 100)),
            .zero
        ]
        let expectation = expectation(description: "Observer was called")
        expectation.expectedFulfillmentCount = 2
        
        // Given
        
        adyenObserver = DummyAdyenObserver()
        adyenObserver!.observe(keyboardObserver.$keyboardRect) { rect in
            XCTAssertEqual(rect, expectedRects.first)
            expectedRects = Array(expectedRects.dropFirst())
            expectation.fulfill()
        }
        
        // When
        
        // Valid Notification
        
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [UIResponder.keyboardFrameEndUserInfoKey: expectedRects]
        )
        
        // In valid Notification
        
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: ["RandomKey": 1]
        )
        
        // Then
        
        wait(for: [expectation], timeout: 2)
        
        XCTAssertEqual(expectedRects.count, 0)
    }
}
