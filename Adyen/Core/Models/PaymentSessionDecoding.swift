//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import Foundation

extension PaymentSession: Decodable {
    
    // MARK: - Decoding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.payment = try container.decode(Payment.self, forKey: .payment)
        self.initiationURL = try container.decode(URL.self, forKey: .initiationURL)
        self.checkoutShopperBaseURL = try container.decode(URL.self, forKey: .checkoutShopperBaseURL)
        self.deleteStoredPaymentMethodURL = try container.decode(URL.self, forKey: .deleteStoredPaymentMethodURL)
        self.publicKey = try container.decodeIfPresent(String.self, forKey: .publicKey)
        self.generationDate = try container.decodeIfPresent(Date.self, forKey: .generationDate)
        self.paymentData = try container.decode(String.self, forKey: .paymentData)
        self.company = try container.decodeIfPresent(Company.self, forKey: .company)
        self.lineItems = try container.decodeIfPresent([LineItem].self, forKey: .lineItems)
        
        self.paymentMethods = try SectionedPaymentMethods(from: decoder)
        
        fillInLogoURLs()
    }
    
    private enum CodingKeys: String, CodingKey {
        case payment
        case paymentMethods
        case storedPaymentMethods = "oneClickPaymentMethods"
        case environment
        case initiationURL = "initiationUrl"
        case checkoutShopperBaseURL = "checkoutshopperBaseUrl"
        case deleteStoredPaymentMethodURL = "disableRecurringDetailUrl"
        case publicKey
        case generationDate = "generationtime"
        case paymentData
        case lineItems
        case company
    }
    
    // MARK: - Decoding Response
    
    /// Creates and returns a payment session by decoding it from the response of the /paymentSession endpoint.
    /// This supports both passing the full response, as well as just passing the value of "paymentSession" in the JSON object.
    ///
    /// - Parameter responseString: The string value of the /paymentSession response.
    /// - Returns: A payment session.
    /// - Throws: An error if decoding fails.
    internal static func decode(from responseString: String) throws -> PaymentSession {
        // If the responseString is base64, decode it and pass it to Coder.
        if let paymentSessionData = Data(base64Encoded: responseString) {
            return try Coder.decode(paymentSessionData) as PaymentSession
        }
        
        // If it's not a base64 string, handle it as a JSON string.
        guard let json = try JSONSerialization.jsonObject(with: Data(responseString.utf8), options: []) as? [String: Any] else { throw decodingError }
        guard let paymentSessionBase64 = json["paymentSession"] as? String else { throw decodingError }
        guard let paymentSessionData = Data(base64Encoded: paymentSessionBase64) else { throw decodingError }
        
        return try Coder.decode(paymentSessionData)
    }
    
    private static var decodingError: Error {
        let context = DecodingError.Context(codingPath: [], debugDescription: "The given response string is not a valid payment session.")
        
        return DecodingError.dataCorrupted(context)
    }
    
    // MARK: - Private
    
    private mutating func fillInLogoURLs() {
        paymentMethods.preferred = paymentMethodsWithLogoURLs(paymentMethods.preferred)
        paymentMethods.other = paymentMethodsWithLogoURLs(paymentMethods.other)
    }
    
    private func paymentMethodsWithLogoURLs(_ paymentMethods: [PaymentMethod]) -> [PaymentMethod] {
        var mutatedPaymentMethods: [PaymentMethod] = []
        
        for var paymentMethod in paymentMethods {
            let logoURL = LogoURLProvider.logoURL(for: paymentMethod, baseURL: checkoutShopperBaseURL)
            paymentMethod.logoURL = logoURL
            
            if let issuerDetail = paymentMethod.details.issuer, case let .select(issuers) = issuerDetail.inputType {
                let issuersWithLogoURLs = issuers.map { issuer -> PaymentDetail.SelectItem in
                    var issuerWithLogoURL = issuer
                    issuerWithLogoURL.logoURL = LogoURLProvider.logoURL(for: paymentMethod, selectItem: issuer, baseURL: checkoutShopperBaseURL)
                    
                    return issuerWithLogoURL
                }
                
                paymentMethod.details.issuer?.inputType = .select(issuersWithLogoURLs)
            }
            
            paymentMethod.children = paymentMethodsWithLogoURLs(paymentMethod.children)
            mutatedPaymentMethods.append(paymentMethod)
        }
        
        return mutatedPaymentMethods
    }
    
}
