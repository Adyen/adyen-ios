//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An issuer (typically a bank) in an issuer list payment method.
public struct Issuer: Decodable, CustomStringConvertible, Equatable {

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

    // MARK: - Coding
 
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(PaymentMethodType.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.issuers = try container.decode([Issuer].self, forKey: .issuers)
    }

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
