//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the redirect component.
public struct RedirectDetails: AdditionalDetails, Decodable {
    
    /// Indicates an error with the `RedirectDetails` initiallization.
    public enum Error: LocalizedError {
        
        /// Indicates that the provided url to initialize a new instance of `RedirectDetails` is invalid.
        case invalidUrl
        
        public var errorDescription: String? {
            "Couldn't find payload, redirectResult or PaRes/md keys in the query parameters."
        }
    }
    
    /// Redirect `payload` if available.
    public private(set) var payload: String?
    
    /// Redirect result if available.
    public private(set) var redirectResult: String?
    
    /// Redirect `PaRes` if available.
    public private(set) var paymentResponse: String?
    
    /// Redirect `MD` or merchant data if available.
    public private(set) var merchantData: String?
    
    /// Redirect raw query parameters in case they're unrecognizable.
    public private(set) var queryString: String?
    
    /// Initializes the redirect payment details.
    ///
    /// - Parameter:
    ///   - returnURL: The URL through which the user returned to the app after a redirect.
    public init(returnURL: URL) throws {
        let queryParameters = returnURL.adyen.queryParameters
        
        if let redirectResult = queryParameters[CodingKeys.redirectResult.rawValue]?.removingPercentEncoding {
            self.redirectResult = redirectResult
        } else if let payload = queryParameters[CodingKeys.payload.rawValue]?.removingPercentEncoding {
            self.payload = payload
        } else if let paymentResponse = queryParameters[CodingKeys.paymentResponse.rawValue]?.removingPercentEncoding,
                  let merchantData = queryParameters[CodingKeys.merchantData.rawValue]?.removingPercentEncoding {
            self.paymentResponse = paymentResponse
            self.merchantData = merchantData
        } else if let queryString = returnURL.query {
            self.queryString = queryString
        } else {
            throw Error.invalidUrl
        }
    }
    
    // MARK: - Internal
    
    internal enum CodingKeys: String, CodingKey {
        case payload
        case redirectResult
        case paymentResponse = "PaRes"
        case merchantData = "MD"
        case queryString = "returnUrlQueryString"
    }
    
}
