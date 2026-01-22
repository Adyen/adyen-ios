//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Response data obtained from the `/sessions` call.
public struct SessionResponse: Decodable, Sendable {
    
    package let sessionIdentifier: String
    
    package let sessionData: String
    
    /// Initializes a new SessionResponse object
    ///
    /// - Parameters:
    ///   - sessionIdentifier: The session identifier.
    ///   - sessionData: The session data.
    public init(
        sessionIdentifier: String,
        sessionData: String
    ) {
        self.sessionIdentifier = sessionIdentifier
        self.sessionData = sessionData
    }
    
    private enum CodingKeys: String, CodingKey {
        case sessionIdentifier = "id"
        case sessionData
    }
}
