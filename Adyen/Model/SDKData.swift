//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public struct SDKData: Codable {
    
    internal struct Analytics: Codable {
        internal let checkoutAttemptId: String
    }
    
    public struct Authentication: Codable {
        internal let threeDS2SdkVersion: String
        
        public init(threeDS2SdkVersion: String) {
            self.threeDS2SdkVersion = threeDS2SdkVersion
        }
    }

    public enum PaymentMethodBehavior: String, Codable {
        /// Indicates that the SDK has a specific component for this payment method.
        case nativeComponent

        /// Indicates that the SDK does not have native component support for this payment method
        /// and will handle it through the Instant Payment Component.
        case genericComponent
    }

    internal let analytics: Analytics
    internal private(set) var authentication: Authentication?
    internal let schemaVersion: Int = SchemaVersions.v1
    private let supportNativeRedirect: Bool = true
    private let timestamp = Int(Date().timeIntervalSince1970 * 1000)

    private let paymentMethodBehavior: PaymentMethodBehavior
    private let channel: String = checkoutPlatformParams.channel
    private let platform: String = checkoutPlatformParams.platform.rawValue
    private let sdkVersion: String = checkoutPlatformParams.version

    @_spi(AdyenInternal)
    public var encodedValue: String? {
        try? AdyenCoder.encodeBase64(self)
    }
    
    internal init(
        checkoutAttemptId: String,
        paymentMethodBehavior: PaymentMethodBehavior,
        authenticationProvider: SDKDataAuthenticationProvider? = nil
    ) {
        self.analytics = .init(checkoutAttemptId: checkoutAttemptId)
        self.paymentMethodBehavior = paymentMethodBehavior
        self.authentication = authenticationProvider?.authentication
    }
    
    private enum CodingKeys: String, CodingKey {
        case analytics
        case authentication
        case supportNativeRedirect
        case schemaVersion
        case timestamp = "createdAt"
        case paymentMethodBehavior
        case channel
        case platform
        case sdkVersion
    }
    
    private enum SchemaVersions {
        internal static let v1 = 1
    }
}

@_spi(AdyenInternal)
public protocol SDKDataAuthenticationProvider {
    var authentication: SDKData.Authentication { get }
}

@_spi(AdyenInternal)
public extension PaymentComponent {

    var paymentMethodBehavior: SDKData.PaymentMethodBehavior {
        .nativeComponent
    }
}

@_spi(AdyenInternal)
public extension InstantPaymentComponent {

    var paymentMethodBehavior: SDKData.PaymentMethodBehavior {
        .genericComponent
    }
}
