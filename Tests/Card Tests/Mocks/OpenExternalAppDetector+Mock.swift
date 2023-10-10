//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import AdyenActions

struct MockOpenExternalAppDetector: OpenExternalAppDetector {
    var didOpenExternalApp: Bool
    func checkIfExternalAppDidOpen(_ completion: @escaping (Bool) -> Void) {
        completion(didOpenExternalApp)
    }
}
