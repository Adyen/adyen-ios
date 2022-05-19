//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Handles opening third party apps.
@_spi(AdyenInternal)
public protocol AnyAppLauncher {
    func openCustomSchemeUrl(_ url: URL, completion: ((Bool) -> Void)?)
    func openUniversalAppUrl(_ url: URL, completion: ((Bool) -> Void)?)
}

/// Handles opening third party apps.
@_spi(AdyenInternal)
public struct AppLauncher: AnyAppLauncher {

    public init() { /* Empty initializer */ }
    
    public func openCustomSchemeUrl(_ url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    public func openUniversalAppUrl(_ url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url,
                                  options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true],
                                  completionHandler: completion)
    }
    
}
