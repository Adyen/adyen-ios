//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An issuer list payment method, such as iDEAL or Open Banking.
public struct IssuerListPaymentMethod: PaymentMethod {
    
    /// :nodoc:
    public let type: String
    
    /// :nodoc:
    public let name: String
    
    /// The available issuers.
    public let issuers: [Issuer]
    
    // MARK: - Issuer
    
    /// An issuer (typically a bank) in an issuer list payment method.
    public struct Issuer: Decodable {
        
        /// The unique identifier of the issuer.
        public let identifier: String
        
        /// The name of the issuer.
        public let name: String
        
        // MARK: - Coding
        
        private enum CodingKeys: String, CodingKey {
            case identifier = "id"
            case name
        }
    }
    
    // MARK: - Coding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)

        let detailsContainer = try? container.nestedUnkeyedContainer(forKey: .details)

        if var detailsContainer {
            var issuers = [Issuer]()

            while !detailsContainer.isAtEnd {
                let detailContainer = try detailsContainer.nestedContainer(keyedBy: CodingKeys.self)
                let detailKey = try detailContainer.decode(String.self, forKey: .key)
                guard detailKey == "issuer" else {
                    continue
                }

                issuers = try detailContainer.decode([Issuer].self, forKey: .items)
            }

            self.issuers = issuers
        } else {
            self.issuers = try container.decode([Issuer].self, forKey: .issuers)
        }
    }
    
    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case details
        case key
        case items
        case issuers
    }
    
}
