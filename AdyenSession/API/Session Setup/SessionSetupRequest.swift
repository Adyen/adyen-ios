//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation

internal protocol SessionResponse: Response {
    var sessionData: String { get }
}

/// A protocol that contains payment result values for session calls.
internal protocol SessionPaymentResultAware {
    var resultCode: PaymentsResponse.ResultCode { get }
    
    var sessionResult: String? { get }
}

internal struct SessionSetupRequest: Request {
    internal let path: String
    
    internal var counter: UInt = 0
    
    internal let headers: [String: String] = [:]
    
    internal let queryParameters: [URLQueryItem] = []
    
    internal let method: HTTPMethod = .post
    
    internal let sessionData: String
    
    internal let order: PartialPaymentOrder?
    
    internal typealias ResponseType = SessionSetupResponse
    
    internal typealias ErrorResponseType = APIError
    
    internal init(sessionId: String,
                  sessionData: String,
                  order: PartialPaymentOrder?) {
        self.path = "checkoutshopper/v1/sessions/\(sessionId)/setup"
        self.sessionData = sessionData
        self.order = order
    }
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(sessionData, forKey: .sessionData)
        try container.encodeIfPresent(order?.compactOrder, forKey: .order)
    }
    
    private enum CodingKeys: String, CodingKey {
        case sessionData
        case order
    }
}

internal struct SessionSetupResponse: SessionResponse {
    
    internal let countryCode: String?
    
    internal let shopperLocale: String?
    
    internal let paymentMethods: PaymentMethods
    
    internal let amount: Amount
    
    internal let sessionData: String
    
    internal let configuration: Configuration
    
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
    
    internal struct Configuration: Decodable {
        
        internal let installmentOptions: InstallmentConfiguration?
        
        internal let enableStoreDetails: Bool
        
        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.enableStoreDetails = try container.decodeIfPresent(Bool.self, forKey: .enableStoreDetails) ?? false
            
            var installmentOptions = try container.decodeIfPresent(InstallmentConfiguration.self, forKey: .installmentOptions)
            let showInstallmentAmount = try container.decodeIfPresent(Bool.self, forKey: .showInstallmentAmount) ?? false
            // this flag doesn't come under the installments object, so we decode it here and put it under installments
            installmentOptions?.showInstallmentAmount = showInstallmentAmount
            self.installmentOptions = installmentOptions
        }
        
        internal init(installmentOptions: InstallmentConfiguration? = nil, enableStoreDetails: Bool) {
            self.installmentOptions = installmentOptions
            self.enableStoreDetails = enableStoreDetails
        }
        
        private enum CodingKeys: String, CodingKey {
            case installmentOptions
            case enableStoreDetails
            case showInstallmentAmount
        }
    }
}
