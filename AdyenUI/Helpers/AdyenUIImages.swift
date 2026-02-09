//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

package extension UIImage {

    static var adyenLock: UIImage? {
        image(named: "bento-lock")?.withRenderingMode(.alwaysTemplate)
    }

    static var systemLock: UIImage? {
        UIImage(systemName: "lock")?.withRenderingMode(.alwaysTemplate)
    }

    // MARK: - Private

    /// Loads a named image from the AdyenUI resource bundle with an optional system image fallback.
    ///
    /// - Parameters:
    ///   - name: The name of the image asset in the AdyenUI asset catalog.
    ///   - systemFallback: An SF Symbol name to use when the asset is not found.
    /// - Returns: The resolved `UIImage`. If both the asset and the system fallback are
    ///   unavailable, returns an empty `UIImage`.
    private static func image(named name: String) -> UIImage? {
        UIImage(named: name, in: Bundle.adyenUIInternalResources, compatibleWith: nil)
    }
}
