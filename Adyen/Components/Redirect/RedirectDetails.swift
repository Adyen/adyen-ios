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
        guard let (codingKey, value) = extractResultFromURL() else {
            let context = EncodingError.Context(codingPath: [CodingKeys.payload, CodingKeys.redirectResult],
                                                debugDescription: "Did not find payload or redirectResult keys")
            throw EncodingError.invalidValue(encoder, context)
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(value, forKey: codingKey)
    }
    
    // MARK: - Internal
    
    internal enum CodingKeys: String, CodingKey {
        case payload
        case redirectResult
    }
    
    internal func extractResultFromURL() -> (CodingKeys, String)? {
        let queryParameters = returnURL.queryParameters
        
        if let redirectResult = queryParameters["redirectResult"]?.removingPercentEncoding {
            return (.redirectResult, redirectResult)
        } else if let payload = queryParameters["payload"]?.removingPercentEncoding {
            return (.payload, payload)
        }
        
        return nil
    }
    
}
