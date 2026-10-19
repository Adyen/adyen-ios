//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import Adyen
import XCTest

class KeyboardObserverTests: XCTestCase, AdyenObserver {
    
    func testKeyboardNotificationHandling() throws {
        
        let keyboardObserver = KeyboardObserver()
        
        let validExpectation = expectation(description: "Observer was called (valid notification)")
        let invalidExpectation = expectation(description: "Observer was called (invalid notification)")
        
        var expectedTransitions: [KeyboardTransition] = [
            .init(
                keyboardRect: .init(origin: .zero, size: .init(width: 100, height: 100)),
                animationDuration: 0.42,
                animationOptions: .curveEaseIn
            ),
            .init()
        ]
        
        var expectations: [XCTestExpectation] = [
            validExpectation,
            invalidExpectation
        ]
        
        // Given
        
        observe(keyboardObserver.$keyboardTransition) { transition in
            XCTAssertEqual(transition.keyboardRect, expectedTransitions.first?.keyboardRect)
            XCTAssertEqual(transition.animationDuration, expectedTransitions.first?.animationDuration)
            XCTAssertEqual(transition.animationOptions.rawValue, expectedTransitions.first?.animationOptions.rawValue)
            expectedTransitions = Array(expectedTransitions.dropFirst())
            expectations.first!.fulfill()
            expectations = Array(expectations.dropFirst())
        }
        
        // When
        
        // Valid Notification
        
        let validTransition = try XCTUnwrap(expectedTransitions.first)
        try NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [
                UIResponder.keyboardFrameEndUserInfoKey: validTransition.keyboardRect,
                UIResponder.keyboardAnimationDurationUserInfoKey: validTransition.animationDuration,
                UIResponder.keyboardAnimationCurveUserInfoKey: UIView.AnimationCurve.easeIn.rawValue
            ]
        )
        
        wait(for: [validExpectation], timeout: 10)
        
        // Invalid Notification
        
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: ["RandomKey": 1]
        )

        wait(for: [invalidExpectation], timeout: 10)
        
        XCTAssertEqual(expectedTransitions.count, 0)
    }
}
