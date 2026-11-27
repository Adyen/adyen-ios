//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCardScanner
import XCTest

final class CardScannerAvailabilityTests: XCTestCase {

    func testIsAvailable_withCaptureDeviceAndUsageDescription_returnsTrue() {
        XCTAssertTrue(CardScanner.isAvailable(hasCaptureDevice: true, cameraUsageDescription: "Camera access is needed to scan your card."))
    }

    func testIsAvailable_withoutCaptureDevice_returnsFalse() {
        XCTAssertFalse(CardScanner.isAvailable(hasCaptureDevice: false, cameraUsageDescription: "Camera access is needed to scan your card."))
    }

    func testIsAvailable_withMissingOrEmptyUsageDescription_returnsFalse() {
        for description in [nil, ""] {
            XCTAssertFalse(CardScanner.isAvailable(hasCaptureDevice: true, cameraUsageDescription: description))
        }
    }
}
