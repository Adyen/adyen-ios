//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An issuer (typically a bank) in an issuer list payment method.
public struct Issuer: Codable, CustomStringConvertible, Equatable {

    /// The unique identifier of the issuer.
    public let identifier: String

    /// The name of the issuer.
    public let name: String

    public var description: String {
        name
    }

    // MARK: - Coding
    
    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case name
    }

}

/// Online Banking  payment method.
public struct OnlineBankingPaymentMethod: PaymentMethod {

    public let type: PaymentMethodType

    public let name: String

    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    /// The available issuers.
    public let issuers: [Issuer]

    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }

    // MARK: - Private
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case issuers
    }

}
