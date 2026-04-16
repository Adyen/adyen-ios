//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import Foundation

// MARK: - Mock

class URLSchemeCheckerMock: URLSchemeChecking {
    var openableSchemes: Set<String> = []

    func canOpen(scheme: String) -> Bool {
        openableSchemes.contains(scheme)
    }
}
