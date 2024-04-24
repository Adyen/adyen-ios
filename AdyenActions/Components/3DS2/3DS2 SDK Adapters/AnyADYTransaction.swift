//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2_Swift
import Foundation
import UIKit

internal protocol AnyADYTransaction {
    var authenticationParameters: AnyAuthenticationRequestParameters { get throws }

    func performChallenge(challengeParameters: ChallengeParameters,
                          presenterViewController: UIViewController,
                          completion: @Sendable @escaping (Result<ChallengeResult, Error>) -> Void)
}

extension Adyen3DS2_Swift.Transaction: AnyADYTransaction {
    func performChallenge(challengeParameters: Adyen3DS2_Swift.ChallengeParameters, presenterViewController: UIViewController, completion: @escaping @Sendable (Result<Adyen3DS2_Swift.ChallengeResult, any Error>) -> Void) {
        self.performChallenge(with: challengeParameters, presenterViewController: presenterViewController, completion: completion)
    }
        
    var authenticationParameters: any AnyAuthenticationRequestParameters {
        get throws {
            try self.authenticationRequestParameters
        }
    }
    
}
