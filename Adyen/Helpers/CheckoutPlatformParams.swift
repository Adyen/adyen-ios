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

    // MARK: - Global shared instance

    public static let shared = CheckoutPlatformParams()

    // MARK: - Properties

    public private(set) var version: String = adyenSdkVersion
    public private(set) var platform: Platform = .ios
    public let channel: String = "ios"

    // MARK: - Initializers

    private init() {}

    // MARK: - Mutation (restricted)

    private let lock = NSLock()

    @_spi(AdyenInternal)
    public func overrideForCrossPlatform(
        platform: Platform,
        version: String
    ) {
        lock.lock()
        defer { lock.unlock() }

        self.version = version
        self.platform = platform
    }
}

@_spi(AdyenInternal)
public let checkoutPlatformParams = CheckoutPlatformParams.shared
