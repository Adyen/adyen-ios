//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

private extension UIApplication.State {
    
    /// Whether or not the application is currently `.active`
    var isActive: Bool {
        switch self {
        case .active, .inactive: return true
        case .background: return false
        @unknown default: return false
        }
    }
}

// MARK: - OpenExternalAppDetecting

/// Detects if an external app was opened
internal protocol OpenExternalAppDetecting: Sendable {
    /// Calls a completion handler indicating whether or not an external app was opened
    func checkIfExternalAppDidOpen(_ completion: @escaping @MainActor @Sendable (_ didOpenExternalApp: Bool) -> Void)
}

// MARK: - OpenExternalAppDetector

internal struct OpenExternalAppDetector: OpenExternalAppDetecting {
    
    private let applicationStateProvider: @MainActor @Sendable () -> UIApplication.State
    private let detectionDelay: DispatchTimeInterval
    
    internal init(
        applicationStateProvider: @escaping @MainActor @Sendable () -> UIApplication.State = { UIApplication.shared.applicationState },
        detectionDelay: DispatchTimeInterval = .seconds(1)
    ) {
        self.applicationStateProvider = applicationStateProvider
        self.detectionDelay = detectionDelay
    }
    
    internal func checkIfExternalAppDidOpen(_ completion: @escaping @MainActor @Sendable (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + detectionDelay) { [applicationStateProvider] in
            MainActor.assumeIsolated {
                completion(!applicationStateProvider().isActive)
            }
        }
    }
}
