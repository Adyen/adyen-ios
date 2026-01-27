//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

/// Response data obtained from the `/sessions` call.
public struct SessionResponse: Decodable, Sendable {
    
    package let id: String
    
    package let sessionData: String
    
    /// Initializes a new SessionResponse object
    ///
    /// - Parameters:
    ///   - id: The session identifier.
    ///   - sessionData: The session data.
    public init(
        id: String,
        sessionData: String
    ) {
        self.id = id
        self.sessionData = sessionData
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case sessionData
    }
}
