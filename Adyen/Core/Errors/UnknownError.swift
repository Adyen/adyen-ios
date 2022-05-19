//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public struct UnknownError: Error, LocalizedError {
    
    public var errorDescription: String?
    
    public init(errorDescription: String? = nil) {
        self.errorDescription = errorDescription
    }
}
