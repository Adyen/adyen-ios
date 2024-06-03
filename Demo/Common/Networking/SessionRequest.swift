//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation
import UIKit

internal struct SessionRequest: APIRequest {
    
    internal typealias ResponseType = SessionResponse
    
    internal let path = "sessions"
    
    internal var counter: UInt = 0
    
    internal var method: HTTPMethod = .post
    
    internal var headers: [String: String] = [:]
    
    internal var queryParameters: [URLQueryItem] = []
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        let currentConfiguration = ConfigurationConstants.current
        
        try container.encode(currentConfiguration.countryCode, forKey: .countryCode)
        try container.encode(Locale.current.identifier, forKey: .shopperLocale)
        try container.encode(ConfigurationConstants.shopperEmail, forKey: .shopperEmail)
        try container.encode(ConfigurationConstants.shopperReference, forKey: .shopperReference)
        try container.encode(currentConfiguration.merchantAccount, forKey: .merchantAccount)
        try container.encode(currentConfiguration.amount, forKey: .amount)
        try container.encode(ConfigurationConstants.returnUrl.absoluteString, forKey: .returnUrl)
        try container.encode(ConfigurationConstants.reference, forKey: .reference)
        try container.encode("iOS", forKey: .channel)
        try container.encode(ConfigurationConstants.additionalData, forKey: .additionalData)
        try container.encode(ConfigurationConstants.lineItems, forKey: .lineItems)
        
        if ConfigurationConstants.current.cardSettings.enableInstallments {
            let installmentOptions = ["card": InstallmentOptions(monthValues: [2, 3, 5], includesRevolving: false),
                                      "visa": InstallmentOptions(monthValues: [3, 6, 9], includesRevolving: true)]
    
            try container.encode(installmentOptions, forKey: .installmentOptions)
            try container.encode(ConfigurationConstants.current.cardSettings.showsInstallmentAmount,
                                 forKey: .showInstallmentAmount)
        }

        if ConfigurationConstants.current.cardSettings.showsStorePaymentMethodField {
            AdyenAssertion.assert(message: "API version should be v70 or above to apply card component's store payment method field",
                                  condition: ConfigurationConstants.current.apiVersion < 70)
            try container.encode("askForConsent", forKey: .storePaymentMethodMode)
            try container.encode("CardOnFile", forKey: .recurringProcessingModel)
        }
        
        if ConfigurationConstants.current.dropInSettings.allowDisablingStoredPaymentMethods {
            try container.encode(true, forKey: .showRemovePaymentMethodButton)
        }
    }
    
    internal enum CodingKeys: CodingKey {
        case countryCode
        case merchantAccount
        case amount
        case order
        case returnUrl
        case reference
        case shopperLocale
        case shopperEmail
        case shopperReference
        case channel
        case additionalData
        case lineItems
        case installmentOptions
        case storePaymentMethodMode
        case recurringProcessingModel
        case showInstallmentAmount
        case showRemovePaymentMethodButton
    }
    
}

internal struct SessionResponse: Response {
    
    internal let sessionData: String
    
    internal let sessionId: String
    
    internal enum CodingKeys: String, CodingKey {
        case sessionData
        case sessionId = "id"
    }
}
