//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen

internal protocol ThreeDSConfigurable {
    var configuration: ThreeDSFeatureChecker? { get set }
}

internal protocol ThreeDSFeatureChecker {
    func isFeatureEnabled(_ name: String) -> Bool
}

/// This type creates a ThreeDSServiceable implementation and consumes ThreeDSConfigurable.
internal final class ThreeDSServiceProvider: ThreeDSServiceable, ThreeDSConfigurable {
    
    /// An optional configuration that can be provided to the service provider.
    internal var configuration: ThreeDSFeatureChecker?
    
    private var service: ThreeDSServiceable?
    private let serviceCreationHandler: (ThreeDSFeatureChecker?) -> ThreeDSServiceable

    internal init(
        serviceCreationHandler: @escaping (ThreeDSFeatureChecker?) -> ThreeDSServiceable = createService
    ) {
        self.serviceCreationHandler = serviceCreationHandler
    }
    
    internal func performFingerprint(
        parameters: FingerprintServiceParameters,
        completionHandler: @escaping (Result<any AnyAuthenticationRequestParameters, ThreeDSServiceFingerprintError>) -> Void
    ) {
        self.resetTransaction()
        let service = serviceCreationHandler(configuration)
        self.service = service
        service.performFingerprint(
            parameters: parameters,
            completionHandler: completionHandler
        )
    }
    
    internal func performChallenge(
        with parameters: ChallengeParameters,
        completionHandler: @escaping (Result<any AnyChallengeResult, ThreeDSServiceChallengeError>) -> Void
    ) {
        // The service needs to be already created during the fingerprint step.
        // There is no way a challenge action should happen without a fingerprint action.
        guard let service = self.service else {
            completionHandler(.failure(.transactionNotInitialized))
            return
        }
        service.performChallenge(with: parameters) { result in
            self.resetTransaction()
            completionHandler(result)
        }
    }
    
    internal func resetTransaction() {
        service?.resetTransaction()
        service = nil
    }
    
    internal static func createService(
        configuration: ThreeDSFeatureChecker?
    ) -> ThreeDSServiceable {
        ThreeDSServiceLegacy()
    }
}
