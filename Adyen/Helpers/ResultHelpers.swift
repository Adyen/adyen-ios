//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public extension Result {
    
    func handle(success: (Success) -> Void, failure: (Failure) -> Void) {
        switch self {
        case let .success(successObject):
            success(successObject)
        case let .failure(error):
            failure(error)
        }
    }
}
