//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Cash App Pay payment method
public struct CashAppPayPaymentMethod: PaymentMethod {
   
    public let type: PaymentMethodType
    
    public let name: String
    
    /// Client key that Cash App uses to attribute API calls.
    public let clientId: String
    
    /// ID of the client or brand account that will charge customers.
    public let scopeId: String
    
    public var merchantProvidedDisplayInformation: MerchantCustomDisplayInformation?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(PaymentMethodType.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        
        let configuration = try container.nestedContainer(keyedBy: ConfigurationCodingKeys.self, forKey: .configuration)
        self.clientId = try configuration.decode(String.self, forKey: .clientId)
        self.scopeId = try configuration.decode(String.self, forKey: .scopeId)
    }
    
    @_spi(AdyenInternal)
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    // MARK: - Private

    private enum CodingKeys: String, CodingKey {
        case type
        case name
        case configuration
    }
    
    private enum ConfigurationCodingKeys: String, CodingKey {
        case clientId
        case scopeId
    }
}
