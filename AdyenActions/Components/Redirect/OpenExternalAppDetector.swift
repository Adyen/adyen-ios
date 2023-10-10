//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Detects if an external app was opened
public struct OpenExternalAppDetector {
    /// Calls a completion handler indicating whether or not an external app was opened
    internal var didOpenExternalApp: (_ completion: @escaping (_ didOpenExternalApp: Bool) -> Void) -> Void
}

public extension OpenExternalAppDetector {
    static var live: Self {
        .init { completion in
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) {
                completion(!UIApplication.shared.applicationState.isInForeground)
            }
        }
    }
}

// MARK: - Convenience

private extension UIApplication.State {
    
    /// Whether or not the application is currently in foreground (`.active` or `.inactive`)
    var isInForeground: Bool {
        switch self {
        case .active, .inactive: return true
        case .background: return false
        @unknown default: return false
        }
    }
}
