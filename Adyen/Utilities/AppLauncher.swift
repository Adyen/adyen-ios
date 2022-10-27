//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Handles opening third party apps.
/// :nodoc:
public protocol AnyAppLauncher {
    /// :nodoc:
    func openCustomSchemeUrl(_ url: URL, completion: ((Bool) -> Void)?)
    /// :nodoc:
    func openUniversalAppUrl(_ url: URL, completion: ((Bool) -> Void)?)
}

/// Handles opening third party apps.
/// :nodoc:
public struct AppLauncher: AnyAppLauncher {

    /// :nodoc:
    public init() { /* Empty initializer */ }
    
    /// :nodoc:
    public func openCustomSchemeUrl(_ url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
    
    /// :nodoc:
    public func openUniversalAppUrl(_ url: URL, completion: ((Bool) -> Void)?) {
        UIApplication.shared.open(url,
                                  options: [UIApplication.OpenExternalURLOptionsKey.universalLinksOnly: true],
                                  completionHandler: completion)
    }
    
}
