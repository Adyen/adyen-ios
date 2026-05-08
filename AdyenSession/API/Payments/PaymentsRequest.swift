//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
#if canImport(AdyenActions)
    import AdyenActions
#endif
import Foundation

internal enum SessionError: LocalizedError {
    case unsupportedActionAfterDetails
    
    internal var errorDescription: String? {
        switch self {
        case .unsupportedActionAfterDetails:
            return "Additional details response contained an unsupported follow-up action."
        }
    }
}

internal struct PaymentsRequest: APIRequest {
    internal let path: String
    
    internal var counter: UInt = 0
    
    internal var headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let sessionData: String
    
    internal let data: PaymentComponentData
    
    internal typealias ResponseType = PaymentsResponse
    
    internal init(
        sessionId: String,
        sessionData: String,
        data: PaymentComponentData
    ) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/payments"
        self.sessionData = sessionData
        self.data = data
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(data.paymentMethod.encodable, forKey: .paymentMethod)
        try container.encode(sessionData, forKey: .sessionData)
        try container.encode(data.storePaymentMethod, forKey: .storePaymentMethod)
        try container.encodeIfPresent(
            data.delegatedAuthenticationData,
            forKey: .delegatedAuthenticationData
        )
        try container.encodeIfPresent(data.shopperName, forKey: .shopperName)
        try container.encodeIfPresent(data.emailAddress, forKey: .shopperEmail)
        try container.encodeIfPresent(data.telephoneNumber, forKey: .telephoneNumber)
        try container.encodeIfPresent(data.billingAddress, forKey: .billingAddress)
        try container.encodeIfPresent(data.deliveryAddress, forKey: .deliveryAddress)
        try container.encodeIfPresent(data.socialSecurityNumber, forKey: .socialSecurityNumber)
        try container.encodeIfPresent(data.browserInfo, forKey: .browserInfo)
        try container.encodeIfPresent(data.order?.compactOrder, forKey: .order)
        try container.encodeIfPresent(data.installments, forKey: .installments)
    }
    
    private enum CodingKeys: String, CodingKey {
        case sessionData
        case paymentMethod
        case storePaymentMethod
        case shopperEmail
        case browserInfo
        case shopperName
        case telephoneNumber
        case billingAddress
        case deliveryAddress
        case socialSecurityNumber
        case order
        case delegatedAuthenticationData
        case installments
    }
}

internal struct PaymentsResponse: SessionDataAware, SessionResultAware {
    
    internal let resultCode: CheckoutResultCode
    
    internal let action: Action?

    internal let order: PartialPaymentOrder?
    
    internal let sessionData: String
    
    internal let sessionResult: String?
    
    private enum CodingKeys: String, CodingKey {
        case action
        case order
        case sessionData
        case resultCode
        case sessionResult
    }
}

internal extension PaymentsResponse {
    func asComponentSubmitResult() throws -> SubmitResult {
        if let action {
            return .action(action)
        }
        if let order,
           let remainingAmount = order.remainingAmount,
           remainingAmount.value > 0 {
            throw PartialPaymentError.notSupportedForComponent
        }
        return .completion(resultCode: resultCode.rawValue)
    }
    
    func asAdditionalDetailsResult() throws -> AdditionalDetailsResult {
        if action != nil {
            throw SessionError.unsupportedActionAfterDetails
        }
        return .completion(resultCode: resultCode.rawValue)
    }
}
