//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Handles opening third party apps.
/// :nodoc:
internal protocol AnyAppLauncher {
    func openCustomSchemeUrl(_ url: URL, completion: ((Bool) -> Void)?)
    func openUniversalAppUrl(_ url: URL, completion: ((Bool) -> Void)?)
}

/// Handles opening third party apps.
/// :nodoc:
internal struct AppLauncher: AnyAppLauncher {
    
    /// :nodoc:
    internal func openCustomSchemeUrl(_ url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    /// :nodoc:
    internal func openUniversalAppUrl(_ url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url,
                                  options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true],
                                  completionHandler: completion)
    }
    
}
