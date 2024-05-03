//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// Detects if an external app was opened
internal protocol OpenExternalAppDetector {
    /// Calls a completion handler indicating whether or not an external app was opened
    func checkIfExternalAppDidOpen(_ completion: @escaping (_ didOpenExternalApp: Bool) -> Void)
}

extension UIApplication: OpenExternalAppDetector {
    public func checkIfExternalAppDidOpen(_ completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            guard let self else { return }
            completion(!self.applicationState.isActive)
        }
    }
}

// MARK: - Convenience

private extension UIApplication.State {
    
    /// Whether or not the application is currently `.active`
    var isActive: Bool {
        switch self {
        case .active: return true
        case .background, .inactive: return false
        @unknown default: return false
        }
    }
}
