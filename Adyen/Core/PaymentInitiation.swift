//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains all the data returned from the server when initiating a payment.
internal struct PaymentInitiation {
    
    /// The state of the payment after initiation.
    internal let state: State
    
    /// Original return data received for the payment.
    internal let initialReturnData: String?
    
}

// MARK: - PaymentInitiation.State

internal extension PaymentInitiation {
    
    /// Enum describing the possible states of a payment after initiation.
    internal enum State: Equatable {
        
        /// Indicates that a redirect is required to complete the payment. Includes the URL to redirect to.
        case redirect(url: URL, shouldSubmitRedirectData: Bool)
        
        case completedWithUnknownStatus(payload: String)
        
        /// Indicates that the payment has been completed. Includes the payment status and payload.
        case completed(status: PaymentStatus, payload: String)
        
        /// Indicates that an error occurred. Includes the error that occurred.
        case error(Error)
        
        internal static func ==(lhs: PaymentInitiation.State, rhs: PaymentInitiation.State) -> Bool {
            switch (lhs, rhs) {
            case let (.redirect(url1, shouldSubmit1), .redirect(url2, shouldSubmit2)):
                return url1 == url2 && shouldSubmit1 == shouldSubmit2
            case (let .completed(status1, payload1), let .completed(status2, payload2)):
                return status1 == status2 && payload1 == payload2
            case let (.error(error1), .error(error2)):
                return error1 == error2
            default:
                return false
            }
        }
    }
    
}

// MARK: - Decoding

internal extension PaymentInitiation {
    
    internal init?(dictionary: [String: Any]) {
        guard let stateRawValue = dictionary["type"] as? String else {
            return nil
        }
        
        var state: State!
        switch stateRawValue {
        case "redirect":
            guard
                let path = dictionary["url"] as? String,
                let url = URL(string: path)
            else {
                fallthrough
            }
            
            let shouldSubmitRedirectData: Bool
            if let shouldSubmitRedirectDataString = dictionary["submitPaymentMethodReturnData"] as? String {
                shouldSubmitRedirectData = shouldSubmitRedirectDataString.boolValue() ?? false
            } else {
                shouldSubmitRedirectData = false
            }
            
            state = .redirect(url: url, shouldSubmitRedirectData: shouldSubmitRedirectData)
        case "complete":
            guard
                let statusRawValue = dictionary["resultCode"] as? String,
                let payload = dictionary["payload"] as? String
            else {
                fallthrough
            }
            
            if let status = PaymentStatus(rawValue: statusRawValue) {
                state = .completed(status: status, payload: payload)
            } else if statusRawValue == "unknown" {
                state = .completedWithUnknownStatus(payload: payload)
            } else {
                fallthrough
            }
        case "error":
            var error = Error.unexpectedError
            
            if let errorMessage = dictionary["errorMessage"] as? String {
                error = .serverError(errorMessage)
            }
            
            state = .error(error)
        default:
            return nil
        }
        
        let paymentMethodReturnData: String? = dictionary["paymentMethodReturnData"] as? String
        
        self.init(state: state, initialReturnData: paymentMethodReturnData)
    }
    
}
