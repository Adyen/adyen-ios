//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public class CheckoutPlatformParams {

    // MARK: - Types

    public enum Platform: String {
        case ios
        case reactNative = "react-native"
        case flutter
    }

    // MARK: - Properties

    public private(set) var version: String = adyenSdkVersion
    public private(set) var platform: Platform = .ios
    public let channel: String = "ios"

    // MARK: - Methods

    public func override(version: String, platform: Platform) {
        self.version = version
        self.platform = platform
    }
}

@_spi(AdyenInternal)
public let checkoutPlatformParams = CheckoutPlatformParams()

