//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The response to a payment initiation request.
internal enum PaymentInitiationResponse: Response {
    /// Indicates the payment has been completed.
    case complete(PaymentResult)
    
    /// Indicates a redirect is required to complete the payment.
    case redirect(Redirect)
    
    /// Indicates an error occurred during initiation of the payment.
    case error(Error)
    
    // MARK: - Decoding
    
    internal init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let responseType = try container.decode(String.self, forKey: .type)
        
        switch responseType {
        case "complete":
            self = .complete(try PaymentResult(from: decoder))
        case "redirect":
            self = .redirect(try Redirect(from: decoder))
        case "error", "validation":
            self = .error(try Error(from: decoder))
        default:
            throw DecodingError.dataCorruptedError(forKey: .type, in: container, debugDescription: "Unknown value \"\(responseType)\" for key \"type\".")
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
    
}

// MARK: - PaymentInitiationResponse.Redirect

internal extension PaymentInitiationResponse {
    /// The information required to perform a redirect.
    internal struct Redirect: Decodable {
        /// The URL to redirect the shopper to.
        internal let url: URL
        
        /// A boolean value indicating if the return URL query should be resubmitted.
        internal let shouldSubmitReturnURLQuery: Bool
        
        // MARK: - Decoding
        
        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.url = try container.decode(URL.self, forKey: .url)
            self.shouldSubmitReturnURLQuery = try container.decodeBooleanStringIfPresent(forKey: .shouldSubmitReturnURLQuery) ?? false
        }
        
        private enum CodingKeys: String, CodingKey {
            case url
            case shouldSubmitReturnURLQuery = "submitPaymentMethodReturnData"
        }
        
    }
    
}

// MARK: - PaymentInitiationResponse.Error

internal extension PaymentInitiationResponse {
    /// An error that occurred during the initiation of a payment.
    internal struct Error: LocalizedError, Decodable {
        /// The error code.
        internal let code: String
        
        /// The error message.
        internal let message: String
        
        // MARK: - LocalizedError
        
        internal var errorDescription: String? {
            return message
        }
        
        // MARK: - Decoding
        
        private enum CodingKeys: String, CodingKey {
            case code = "errorCode"
            case message = "errorMessage"
        }
        
    }
    
}
