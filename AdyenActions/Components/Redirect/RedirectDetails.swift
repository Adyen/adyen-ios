//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the redirect component.
public struct RedirectDetails: AdditionalDetails {
    
    /// The URL through which the user returned to the app after a redirect.
    public let returnURL: URL
    
    /// Initializes the redirect payment details.
    ///
    /// - Parameter:
    ///   - returnURL: The URL through which the user returned to the app after a redirect.
    public init(returnURL: URL) {
        self.returnURL = returnURL
    }
    
    // MARK: - Encoding
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        guard let codingKeysValuesPairs = extractKeyValuesFromURL() else {
            let context = EncodingError.Context(codingPath: [CodingKeys.payload,
                                                             .redirectResult,
                                                             .merchantData,
                                                             .paymentResponse],
                                                debugDescription: "Did not find payload, redirectResult or PaRes/md keys")
            throw EncodingError.invalidValue(encoder, context)
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try codingKeysValuesPairs.forEach { codingKey, value in
            try container.encode(value, forKey: codingKey)
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
    
    internal func extractKeyValuesFromURL() -> [(CodingKeys, String)]? {
        let queryParameters = returnURL.queryParameters

        if let redirectResult = queryParameters[CodingKeys.redirectResult.rawValue]?.removingPercentEncoding {
            return [(.redirectResult, redirectResult)]
        } else if let payload = queryParameters[CodingKeys.payload.rawValue]?.removingPercentEncoding {
            return [(.payload, payload)]
        } else if let paymentResponse = queryParameters[CodingKeys.paymentResponse.rawValue]?.removingPercentEncoding,
                  let merchantData = queryParameters[CodingKeys.merchantData.rawValue]?.removingPercentEncoding {
            return [(.paymentResponse, paymentResponse), (.merchantData, merchantData)]
        } else if let queryString = returnURL.query {
            return [(.queryString, queryString)]
        }
        
        return nil
    }
    
}
