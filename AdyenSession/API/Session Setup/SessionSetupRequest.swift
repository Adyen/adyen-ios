//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenNetworking
import Foundation

protocol SessionResponse: Response {
    var sessionData: String { get }
}

/// A protocol that contains payment result values for session calls.
protocol SessionPaymentResultAware {
    var resultCode: PaymentsResponse.ResultCode { get }
    
    var sessionResult: String? { get }
}

struct SessionSetupRequest: Request {
    let path: String
    
    var counter: UInt = 0
    
    let headers: [String: String] = [:]
    
    let queryParameters: [URLQueryItem] = []
    
    let method: HTTPMethod = .post
    
    let sessionData: String
    
    let order: PartialPaymentOrder?
    
    typealias ResponseType = SessionSetupResponse
    
    typealias ErrorResponseType = APIError
    
    init(sessionId: String,
         sessionData: String,
         order: PartialPaymentOrder?) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/setup"
        self.sessionData = sessionData
        self.order = order
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionData, forKey: .sessionData)
        try container.encodeIfPresent(order?.compactOrder, forKey: .order)
    }
    
    private enum CodingKeys: String, CodingKey {
        case sessionData
        case order
    }
}

struct SessionSetupResponse: SessionResponse {
    
    let countryCode: String?
    
    let shopperLocale: String?
    
    let paymentMethods: PaymentMethods
    
    let amount: Amount
    
    let sessionData: String
    
    let configuration: Configuration
    
    private enum CodingKeys: String, CodingKey {
        case countryCode
        case shopperLocale
        case paymentMethods
        case amount
        case sessionData
        case configuration
    }
}

extension SessionSetupResponse {
    
    struct Configuration: Decodable {
        
        let installmentOptions: InstallmentConfiguration?
        
        let enableStoreDetails: Bool
    }
}
