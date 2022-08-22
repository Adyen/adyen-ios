//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public protocol DelegatedAuthenticationAware {
    var delegatedAuthenticationData: DelegatedAuthenticationData? { get }
}

/// Delegated Authentication Data.
public struct DelegatedAuthenticationData: Codable {
    
    /// Attestation object.
    public let sdkOutput: String?
    
    /// Attestation object.
    public let sdkInput: String?
    
    /// Initializes the `DelegatedAuthenticationData`.
    ///
    /// - Parameters:
    ///   - sdkInput: The input data to `ThreeDS2Component`.
    ///   - sdkOutput: The output from the `ThreeDS2Component`.
    public init(sdkInput: String? = nil, sdkOutput: String? = nil) {
        self.sdkInput = sdkInput
        self.sdkOutput = sdkOutput
    }
}
