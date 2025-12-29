//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

/// Contains the details supplied by the Twint component.
public struct TwintDetails: PaymentMethodDetails {

    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?

    /// The payment method type.
    public let type: PaymentMethodType

    /// The payment method subType.
    public let subType: String
    
    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    public var sdkData: String?

    /// Initializes the Twint details.
    /// - Parameters:
    ///   - paymentMethod: Twint payment method.
    ///   - subType: Twint subType.
    public init(
        type: PaymentMethod,
        subType: String
    ) {
        self.type = type.type
        self.subType = subType
    }

    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case subType = "subtype"
        case sdkData
    }
}
