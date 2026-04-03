//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Protocol for checking if a URL scheme can be opened on the device.
@_spi(AdyenInternal)
public protocol URLSchemeChecking {
    func canOpen(scheme: String) -> Bool
}

/// Default implementation using UIApplication.
@_spi(AdyenInternal)
public struct DefaultURLSchemeChecker: URLSchemeChecking {

    public init() {}

    public func canOpen(scheme: String) -> Bool {
        guard let url = URL(string: scheme + "://") else {
            return false
        }
        return UIApplication.shared.canOpenURL(url)
    }
}
