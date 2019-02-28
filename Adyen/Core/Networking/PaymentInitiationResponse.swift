//
// Copyright (c) 2019 Adyen B.V.
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
    
    /// Indicates the shopper needs to be identified before the payment can be completed.
    case identify(Details)
    
    /// Indicates the shopper needs to be challenged before the payment can be completed.
    case challenge(Details)
    
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
        case "identifyShopper":
            self = .identify(try Details(from: decoder))
        case "challengeShopper", "details":
            self = .challenge(try Details(from: decoder))
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
    struct Redirect: Decodable {
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
    struct Error: LocalizedError, Decodable {
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

// MARK: - PaymentInitiationResponse.Details

internal extension PaymentInitiationResponse {
    
    /// Extra details needed to perform the transaction.
    struct Details: Decodable {
        /// The payment method type that need extra details.
        internal let paymentMethodType: String
        
        /// The extra details needed.
        internal let paymentDetails: [PaymentDetail]
        
        /// A collection of arbitrary values required to collect the additional details.
        internal let userInfo: [String: String]
        
        /// The updated state of the payment. If present, should be submitted on following initiation.
        internal let paymentData: String?
        
        /// The return data that when present, should be submitted on following initiation.
        internal let returnData: String?
        
        // MARK: - Decoding
        
        internal init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            self.paymentMethodType = try container.decode([String: String].self, forKey: .paymentMethod)["type"] ?? ""
            self.paymentDetails = try container.decode([PaymentDetail].self, forKey: .paymentDetails)
            self.paymentData = try container.decodeIfPresent(String.self, forKey: .paymentData)
            self.returnData = try container.decodeIfPresent(String.self, forKey: .returnData)
            
            do {
                self.userInfo = try container.decode([String: String].self, forKey: .authenticationData)
            } catch {
                let userInfoError = error
                do {
                    self.userInfo = try container.decode([String: String].self, forKey: .redirectData)
                } catch {
                    throw userInfoError
                }
            }
        }
        
        private enum CodingKeys: String, CodingKey {
            case paymentMethod
            case paymentDetails = "responseDetails"
            case authenticationData = "authentication"
            case redirectData
            case paymentData
            case returnData = "paymentMethodReturnData"
        }
        
    }
    
}
