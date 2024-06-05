//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

// MARK: - ApplicationStateProviding

internal protocol ApplicationStateProviding {
    
    var applicationState: UIApplication.State { get }
}

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

extension UIApplication: ApplicationStateProviding {}

// MARK: - OpenExternalAppDetecting

/// Detects if an external app was opened
internal protocol OpenExternalAppDetecting {
    /// Calls a completion handler indicating whether or not an external app was opened
    func checkIfExternalAppDidOpen(_ completion: @escaping (_ didOpenExternalApp: Bool) -> Void)
}

// MARK: - OpenExternalAppDetector

internal struct OpenExternalAppDetector: OpenExternalAppDetecting {
    
    private let applicationStateProvider: ApplicationStateProviding
    private let detectionDelay: DispatchTimeInterval
    
    internal init(
        applicationStateProvider: ApplicationStateProviding = UIApplication.shared,
        detectionDelay: DispatchTimeInterval = .seconds(1)
    ) {
        self.applicationStateProvider = applicationStateProvider
        self.detectionDelay = detectionDelay
    }
    
    public func checkIfExternalAppDidOpen(_ completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + detectionDelay) {
            completion(!applicationStateProvider.applicationState.isActive)
        }
    }
}
