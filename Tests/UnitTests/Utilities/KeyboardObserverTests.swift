//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class KeyboardObserverTests: XCTestCase, AdyenObserver {
    
    func testKeyboardNotificationHandling() {
        
        let keyboardObserver = KeyboardObserver()
        
        let validExpectation = expectation(description: "Observer was called (valid notification)")
        let invalidExpectation = expectation(description: "Observer was called (invalid notification)")
        
        var expectedRects: [CGRect] = [
            .init(origin: .zero, size: .init(width: 100, height: 100)),
            .zero
        ]
        
        var expectations: [XCTestExpectation] = [
            validExpectation,
            invalidExpectation
        ]
        
        // Given
        
        observe(keyboardObserver.$keyboardRect) { rect in
            XCTAssertEqual(rect, expectedRects.first)
            expectedRects = Array(expectedRects.dropFirst())
            expectations.first!.fulfill()
            expectations = Array(expectations.dropFirst())
        }
        
        // When
        
        // Valid Notification
        
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [UIResponder.keyboardFrameEndUserInfoKey: expectedRects.first!]
        )
        
        wait(for: [validExpectation], timeout: 10)
        
        // Invalid Notification
        
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: ["RandomKey": 1]
        )

        wait(for: [invalidExpectation], timeout: 10)
        
        XCTAssertEqual(expectedRects.count, 0)
    }
}
