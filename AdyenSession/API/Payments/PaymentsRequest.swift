//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
#if canImport(AdyenActions)
    @_spi(AdyenInternal) import AdyenActions
#endif
import CloudKit
import Foundation

internal struct PaymentsRequest: APIRequest {
    internal let path: String
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let sessionData: String
    
    internal let data: PaymentComponentData
    
    internal typealias ResponseType = PaymentsResponse
    
    internal init(sessionId: String,
                  sessionData: String,
                  data: PaymentComponentData) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/payments"
        self.sessionData = sessionData
        self.data = data
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(data.paymentMethod.encodable, forKey: .paymentMethod)
        try container.encode(sessionData, forKey: .sessionData)
        try container.encode(data.supportNativeRedirect, forKey: .supportNativeRedirect)
        try container.encode(data.storePaymentMethod, forKey: .storePaymentMethod)
        try container.encodeIfPresent(data.delegatedAuthenticationData,
                                      forKey: .delegatedAuthenticationData)
        try container.encodeIfPresent(data.shopperName, forKey: .shopperName)
        try container.encodeIfPresent(data.emailAddress, forKey: .shopperEmail)
        try container.encodeIfPresent(data.telephoneNumber, forKey: .telephoneNumber)
        try container.encodeIfPresent(data.billingAddress, forKey: .billingAddress)
        try container.encodeIfPresent(data.deliveryAddress, forKey: .deliveryAddress)
        try container.encodeIfPresent(data.socialSecurityNumber, forKey: .socialSecurityNumber)
        try container.encodeIfPresent(data.browserInfo, forKey: .browserInfo)
        try container.encodeIfPresent(data.checkoutAttemptId, forKey: .checkoutAttemptId)
        try container.encodeIfPresent(data.order?.compactOrder, forKey: .order)
    }
    
    private enum CodingKeys: String, CodingKey {
        case sessionData
        case paymentMethod
        case supportNativeRedirect
        case storePaymentMethod
        case shopperEmail
        case browserInfo
        case checkoutAttemptId
        case shopperName
        case telephoneNumber
        case billingAddress
        case deliveryAddress
        case socialSecurityNumber
        case order
        case delegatedAuthenticationData
    }
}

internal struct PaymentsResponse: SessionResponse, PaymentResultCodeAware {
    
    internal let resultCode: ResultCode
    
    internal let action: Action?

    internal let order: PartialPaymentOrder?
    
    internal let sessionData: String
    
    private enum CodingKeys: String, CodingKey {
        case action
        case order
        case sessionData
        case resultCode
    }
}

internal extension PaymentsResponse {
    
    // swiftlint:disable:next explicit_acl
    enum ResultCode: String, Decodable {
        case authenticationFinished = "AuthenticationFinished"
        case authenticationNotRequired = "AuthenticationNotRequired"
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
