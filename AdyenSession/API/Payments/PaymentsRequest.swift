//
// Copyright (c) 2023 Adyen N.V.
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

struct PaymentsRequest: APIRequest {
    let path: String
    
    var counter: UInt = 0
    
    let headers: [String: String] = [:]
    
    let queryParameters: [URLQueryItem] = []
    
    let method: HTTPMethod = .post
    
    let sessionData: String
    
    let data: PaymentComponentData
    
    typealias ResponseType = PaymentsResponse
    
    init(sessionId: String,
         sessionData: String,
         data: PaymentComponentData) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/payments"
        self.sessionData = sessionData
        self.data = data
    }
    
    func encode(to encoder: Encoder) throws {
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

struct PaymentsResponse: SessionResponse, SessionPaymentResultAware {
    
    let resultCode: ResultCode
    
    let action: Action?

    let order: PartialPaymentOrder?
    
    let sessionData: String
    
    let sessionResult: String?
    
    private enum CodingKeys: String, CodingKey {
        case action
        case order
        case sessionData
        case resultCode
        case sessionResult
    }
}

extension PaymentsResponse {
    
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
