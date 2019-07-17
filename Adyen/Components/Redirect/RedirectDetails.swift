//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the details supplied by the redirect component.
public struct RedirectDetails: AdditionalDetails {
    
    /// The URL through which the user returned to the app after a redirect.
    public let returnURL: URL
    
    /// Initializes the redirect payment details.
    ///
    /// - Parameter:
    ///   - returnURL: The URL through which the user returned to the app after a redirect.
    internal init(returnURL: URL) {
        self.returnURL = returnURL
    }
    
    // MARK: - Encoding
    
    /// :nodoc:
    public func encode(to encoder: Encoder) throws {
        guard let codingKeysValuesPairs = extractKeyValuesFromURL() else {
            let context = EncodingError.Context(codingPath: [CodingKeys.payload, .redirectResult, .md, .paymentResponse],
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
        case md = "MD"
    }
    
    internal func extractKeyValuesFromURL() -> [(CodingKeys, String)]? {
        let queryParameters = returnURL.queryParameters
        
        if let redirectResult = queryParameters["redirectResult"]?.removingPercentEncoding {
            return [(.redirectResult, redirectResult)]
        } else if let payload = queryParameters["payload"]?.removingPercentEncoding {
            return [(.payload, payload)]
        } else if let paymentResponse = queryParameters["PaRes"]?.removingPercentEncoding, let md = queryParameters["MD"]?.removingPercentEncoding {
            return [(.paymentResponse, paymentResponse), (.md, md)]
        }
        
        return nil
    }
    
}
