//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenActions

public extension OpenExternalAppDetector {
    static func mock(didOpenExternalApp: Bool) -> Self {
        .init { completion in
            completion(didOpenExternalApp)
        }
    }
}
