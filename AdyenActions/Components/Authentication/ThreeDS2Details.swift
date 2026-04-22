//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

// TODO: Robert: AuthenticationComponent: We can look to remove this type completely and use the threeDSResult directly.
/// Holds the results of the 3D Secure 2 component.
internal enum ThreeDS2Details: AdditionalDetails {

    /// When a 3DS flow is completed.
    case completed(ThreeDSResult)

    // MARK: - Encoding
    
    internal func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case let .completed(result):
            try container.encode(result.payload, forKey: .threeDSResult)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case threeDSResult
    }
    
}
