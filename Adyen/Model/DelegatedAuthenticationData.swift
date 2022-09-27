//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any object that is aware of `DelegatedAuthenticationData`.
@_spi(AdyenInternal)
public protocol DelegatedAuthenticationAware {
    var delegatedAuthenticationData: DelegatedAuthenticationData? { get }
}

/// Delegated Authentication Data.
public enum DelegatedAuthenticationData: Codable {
    
    /// Describes any error that occurs while decoding the `DelegatedAuthenticationData`.
    public enum DecodingError: LocalizedError {
        case invalidDelegatedAuthenticationData
        
        public var errorDescription: String? {
            "Delegated Authentication object is invalid"
        }
    }
    
    case sdkOutput(String)
    case sdkInput(String)
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let sdkOutput = try container.decodeIfPresent(String.self, forKey: .sdkOutput)
        let sdkInput = try container.decodeIfPresent(String.self, forKey: .sdkInput)
        
        switch (sdkOutput, sdkInput) {
        case (nil, nil):
            throw DecodingError.invalidDelegatedAuthenticationData
        case (.some, .some):
            throw DecodingError.invalidDelegatedAuthenticationData
        case (let .some(sdkOutput), nil):
            self = .sdkOutput(sdkOutput)
        case (nil, let .some(sdkInput)):
            self = .sdkInput(sdkInput)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .sdkInput(sdkInput):
            try container.encode(sdkInput, forKey: .sdkInput)
        case let .sdkOutput(sdkOutput):
            try container.encode(sdkOutput, forKey: .sdkOutput)
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case sdkOutput
        case sdkInput
    }
}
