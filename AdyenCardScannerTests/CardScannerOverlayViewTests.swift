//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import XCTest

final class CardScannerOverlayViewTests: XCTestCase {

    func test_roiFrame_isResolvedAfterSingleLayoutPass() {
        let sut = CardScannerOverlayView(frame: CGRect(x: 0, y: 0, width: 414, height: 838))

        sut.setNeedsLayout()
        sut.layoutIfNeeded()

        let expectedWidth: CGFloat = 414 - 24
        let expectedHeight = expectedWidth / 1.585
        XCTAssertEqual(sut.roiFrame.width, expectedWidth, accuracy: 0.5)
        XCTAssertEqual(sut.roiFrame.height, expectedHeight, accuracy: 0.5)
        XCTAssertEqual(sut.roiFrame.midX, 207, accuracy: 0.5)
        XCTAssertEqual(sut.roiFrame.midY, 419, accuracy: 0.5)
    }
}
