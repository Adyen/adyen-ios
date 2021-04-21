//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Contains the details supplied by the MB Way await component.
public struct AwaitActionDetails: AdditionalDetails {
    
    /// The payload.
    public let payload: String
    
    /// Initializes the MB Way await action details.
    ///
    ///
    /// - Parameters:
    ///   - payload: The payload.
    public init(payload: String) {
        self.payload = payload
    }
    
    private enum CodingKeys: String, CodingKey {
        case payload
    }
    
}
