//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// So that any `Bundle` instance will inherit the `adyen` scope.
/// :nodoc:
extension Bundle: AdyenCompatible {}

/// Adds helper functionality to any `Bundle` instance through the `adyen` property.
/// :nodoc:
extension AdyenScope where Base: Bundle {
    
    /// Enables any `Bundle` instance to check whether a certain scheme is whitlisted in the Info.plist or not.
    /// :nodoc:
    public func isSchemeWhitelisted(_ scheme: String) -> Bool {
        guard let appSchemesWhitlist = base.object(forInfoDictionaryKey: "LSApplicationQueriesSchemes") as? [String] else {
            return false
        }
        guard appSchemesWhitlist.contains(where: { $0.lowercased() == scheme.lowercased() }) else {
            return false
        }
        return true
    }
    
}
