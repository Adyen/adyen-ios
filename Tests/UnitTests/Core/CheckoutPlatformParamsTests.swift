//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@_spi(AdyenInternal) @testable import Adyen

class CheckoutPlatformParamsTests: XCTestCase {

    func test_default_values() {
        let sut = CheckoutPlatformParams.shared

        XCTAssertEqual(sut.version, adyenSdkVersion)
        XCTAssertEqual(sut.platform, .ios)
        XCTAssertEqual(sut.channel, "ios")
    }

    func test_override_updates_version_and_platform() {
        let sut = CheckoutPlatformParams.shared
        let originalVersion = sut.version
        let originalPlatform = sut.platform

        // When
        sut.override(version: "1.0.0", platform: .flutter)

        // Then
        XCTAssertEqual(sut.version, "1.0.0")
        XCTAssertEqual(sut.platform, .flutter)

        // Cleanup - restore original values
        sut.override(version: originalVersion, platform: originalPlatform)
    }

    func test_override_with_react_native_platform() {
        let sut = CheckoutPlatformParams.shared
        let originalVersion = sut.version
        let originalPlatform = sut.platform

        // When
        sut.override(version: "2.0.0", platform: .reactNative)

        // Then
        XCTAssertEqual(sut.version, "2.0.0")
        XCTAssertEqual(sut.platform, .reactNative)
        XCTAssertEqual(sut.platform.rawValue, "react-native")

        // Cleanup - restore original values
        sut.override(version: originalVersion, platform: originalPlatform)
    }

    func test_channel_is_always_ios() {
        let sut = CheckoutPlatformParams.shared
        let originalVersion = sut.version
        let originalPlatform = sut.platform

        // When - override to different platform
        sut.override(version: "1.0.0", platform: .flutter)

        // Then - channel should still be ios
        XCTAssertEqual(sut.channel, "ios")

        // Cleanup
        sut.override(version: originalVersion, platform: originalPlatform)
    }

    func test_shared_returns_same_instance() {
        let instance1 = CheckoutPlatformParams.shared
        let instance2 = CheckoutPlatformParams.shared

        XCTAssertTrue(instance1 === instance2)
    }

    func test_checkoutPlatformParams_global_returns_shared_instance() {
        XCTAssertTrue(checkoutPlatformParams === CheckoutPlatformParams.shared)
    }
}
