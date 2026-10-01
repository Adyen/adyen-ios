//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

class KeyboardObserverTests: XCTestCase, AdyenObserver {
    
    func testKeyboardNotificationHandling() throws {
        
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
        
        try NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [UIResponder.keyboardFrameEndUserInfoKey: XCTUnwrap(expectedRects.first)]
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

    func testTransientHideBetweenFramesIsNotPublished() {
        let keyboardObserver = KeyboardObserver()
        let firstFrame = CGRect(x: 0, y: 100, width: 100, height: 100)
        let secondFrame = CGRect(x: 0, y: 120, width: 100, height: 80)
        var publishedRects: [CGRect] = []
        observe(keyboardObserver.$keyboardRect) { publishedRects.append($0) }

        postKeyboardFrame(firstFrame)
        postKeyboardFrame(.zero)
        postKeyboardFrame(secondFrame)
        wait(for: .milliseconds(300))

        XCTAssertEqual(publishedRects, [firstFrame, secondFrame])
    }

    func testHideIsPublishedAfterDelay() {
        let keyboardObserver = KeyboardObserver()
        let frame = CGRect(x: 0, y: 100, width: 100, height: 100)
        var publishedRects: [CGRect] = []
        observe(keyboardObserver.$keyboardRect) { publishedRects.append($0) }

        postKeyboardFrame(frame)
        postKeyboardFrame(CGRect(x: 0, y: 5000, width: 100, height: 100))
        XCTAssertEqual(publishedRects, [frame])

        wait(for: .milliseconds(300))

        XCTAssertEqual(publishedRects, [frame, .zero])
    }

    func testFrameChangesWhileVisibleAreCoalesced() {
        let keyboardObserver = KeyboardObserver()
        let firstFrame = CGRect(x: 0, y: 100, width: 100, height: 100)
        let finalFrame = CGRect(x: 0, y: 150, width: 100, height: 50)
        var publishedRects: [CGRect] = []
        observe(keyboardObserver.$keyboardRect) { publishedRects.append($0) }

        postKeyboardFrame(firstFrame)
        postKeyboardFrame(CGRect(x: 0, y: 190, width: 100, height: 10))
        postKeyboardFrame(finalFrame)
        XCTAssertEqual(publishedRects, [firstFrame])

        wait(for: .milliseconds(300))

        XCTAssertEqual(publishedRects, [firstFrame, finalFrame])
    }

    func testTallerKeyboardIsPublishedImmediately() {
        let keyboardObserver = KeyboardObserver()
        let firstFrame = CGRect(x: 0, y: 100, width: 100, height: 100)
        let tallerFrame = CGRect(x: 0, y: 50, width: 100, height: 150)
        var publishedRects: [CGRect] = []
        observe(keyboardObserver.$keyboardRect) { publishedRects.append($0) }

        postKeyboardFrame(firstFrame)
        postKeyboardFrame(CGRect(x: 0, y: 190, width: 100, height: 10))
        postKeyboardFrame(tallerFrame)
        XCTAssertEqual(publishedRects, [firstFrame, tallerFrame])

        wait(for: .milliseconds(300))

        XCTAssertEqual(publishedRects, [firstFrame, tallerFrame])
    }

    private func postKeyboardFrame(_ frame: CGRect) {
        NotificationCenter.default.post(
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil,
            userInfo: [UIResponder.keyboardFrameEndUserInfoKey: frame]
        )
    }
}
