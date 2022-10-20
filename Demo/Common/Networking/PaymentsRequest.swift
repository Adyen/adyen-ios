//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenNetworking
import Foundation

internal struct PaymentsRequest: APIRequest {
    
    internal typealias ResponseType = PaymentsResponse
    
    internal let path = "payments"
    
    internal let data: PaymentComponentData
    
    internal var counter: UInt = 0
    
    internal var method: HTTPMethod = .post
    
    internal var queryParameters: [URLQueryItem] = []
    
    internal var headers: [String: String] = [:]
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let currentConfiguration = ConfigurationConstants.current

        // Important: for the demo purpose we are setting amount here.
        // If you choose not to provide amount to the payment component - it could be specified by your backend.
        let amount = data.amountToPay ?? currentConfiguration.amount
        
        try container.encode(data.paymentMethod.encodable, forKey: .details)
        try container.encode(data.supportNativeRedirect, forKey: .supportNativeRedirect)
        try container.encode(data.storePaymentMethod, forKey: .storePaymentMethod)
        try container.encodeIfPresent(data.delegatedAuthenticationData,
                                      forKey: .delegatedAuthenticationData)
        try container.encodeIfPresent(data.shopperName, forKey: .shopperName)
        try container.encodeIfPresent(data.emailAddress ?? ConfigurationConstants.shopperEmail, forKey: .shopperEmail)
        try container.encodeIfPresent(data.telephoneNumber, forKey: .telephoneNumber)
        try container.encodeIfPresent(data.billingAddress, forKey: .billingAddress)
        try container.encodeIfPresent(data.deliveryAddress, forKey: .deliveryAddress)
        try container.encodeIfPresent(data.socialSecurityNumber, forKey: .socialSecurityNumber)
        try container.encode(Locale.current.identifier, forKey: .shopperLocale)
        try container.encodeIfPresent(data.browserInfo, forKey: .browserInfo)
        try container.encode("iOS", forKey: .channel)
        try container.encode(amount, forKey: .amount)
        try container.encode(ConfigurationConstants.reference, forKey: .reference)
        try container.encode(currentConfiguration.countryCode, forKey: .countryCode)
        try container.encode(ConfigurationConstants.returnUrl, forKey: .returnUrl)
        try container.encode(ConfigurationConstants.shopperReference, forKey: .shopperReference)
        try container.encode(ConfigurationConstants.additionalData, forKey: .additionalData)
        try container.encode(currentConfiguration.merchantAccount, forKey: .merchantAccount)
        try container.encodeIfPresent(data.order?.compactOrder, forKey: .order)
        try container.encodeIfPresent(data.installments, forKey: .installments)
        try container.encode(ConfigurationConstants.lineItems, forKey: .lineItems)
    }
    
    private enum CodingKeys: String, CodingKey {
        case details = "paymentMethod"
        case supportNativeRedirect
        case storePaymentMethod
        case amount
        case reference
        case channel
        case countryCode
        case returnUrl
        case shopperReference
        case shopperEmail
        case additionalData
        case merchantAccount
        case browserInfo
        case checkoutAttemptId
        case shopperName
        case telephoneNumber
        case shopperLocale
        case billingAddress
        case deliveryAddress
        case socialSecurityNumber
        case order
        case installments
        case lineItems
        case delegatedAuthenticationData
    }
    
}

internal struct PaymentsResponse: Response {

    internal static var received: PaymentsResponse = .init()
    
    internal let resultCode: ResultCode
    
    internal let action: Action?

    internal let order: PartialPaymentOrder?

    internal let refusalReason: String?

    internal let refusalReasonCode: String?

    internal let amount: Amount?
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.resultCode = try container.decode(ResultCode.self, forKey: .resultCode)
        self.action = try container.decodeIfPresent(Action.self, forKey: .action)
        self.order = try container.decodeIfPresent(PartialPaymentOrder.self, forKey: .order)
        self.refusalReasonCode = try container.decodeIfPresent(String.self, forKey: .refusalReasonCode)
        self.amount = try container.decodeIfPresent(Amount.self, forKey: .amount)
        if let additionalData = try? container.nestedContainer(keyedBy: CodingKeys.self, forKey: .additionalData) {
            self.refusalReason = try additionalData.decodeIfPresent(String.self, forKey: .refusalReason)
        } else {
            self.refusalReason = nil
        }
    }

    private init() {
        resultCode = .received
        action = nil
        order = nil
        amount = nil
        refusalReasonCode = nil
        refusalReason = nil
    }
    
    private enum CodingKeys: String, CodingKey {
        case resultCode
        case action
        case order
        case refusalReason = "refusalReasonRaw"
        case refusalReasonCode
        case additionalData
        case amount
    }
    
}

internal extension PaymentsResponse {
    
    // swiftlint:disable:next explicit_acl
    enum ResultCode: String, Decodable {
        case authorised = "Authorised"
        case refused = "Refused"
        case pending = "Pending"
        case cancelled = "Cancelled"
        case error = "Error"
        case received = "Received"
        case redirectShopper = "RedirectShopper"
        case identifyShopper = "IdentifyShopper"
        case challengeShopper = "ChallengeShopper"
        case presentToShopper = "PresentToShopper"
    }
    
}
