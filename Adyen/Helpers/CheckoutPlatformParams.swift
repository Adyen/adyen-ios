//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import os

@_spi(AdyenInternal)
/// Reference to the Android counterpart: https://github.com/Adyen/adyen-android/blob/main/core/src/main/java/com/adyen/checkout/core/common/internal/helper/CheckoutPlatformParams.kt
public final class CheckoutPlatformParams: Sendable {

    // MARK: - Types

    public enum Platform: String, Sendable {
        case ios
        case reactNative = "react-native"
        case flutter
    }

    private struct State {
        internal var version: String
        internal var platform: Platform
    }

    // MARK: - Global shared instance

    public static let shared = CheckoutPlatformParams()

    // MARK: - Properties

    private let state: OSAllocatedUnfairLock<State>
    // TODO: Robert: Swift6: This may be of a concern. Have a closer look at this. Why cant this be on the main actor instea of usign locks?
    public var version: String {
        state.withLock { $0.version }
    }

    public var platform: Platform {
        state.withLock { $0.platform }
    }

    public let channel: String = "ios"

    // MARK: - Initializers

    private init() {
        state = OSAllocatedUnfairLock(initialState: State(version: adyenSdkVersion, platform: .ios))
    }

    /// Internal initializer for testing purposes.
    internal init(version: String, platform: Platform) {
        state = OSAllocatedUnfairLock(initialState: State(version: version, platform: platform))
    }

    // MARK: - Mutation (restricted)

    @_spi(AdyenInternal)
    public func overrideForCrossPlatform(
        platform: Platform,
        version: String
    ) {
        state.withLock {
            $0.platform = platform
            $0.version = version
        }
    }
}

@_spi(AdyenInternal)
public let checkoutPlatformParams = CheckoutPlatformParams.shared
