//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

internal protocol AnyADYTransaction {

    var authenticationParameters: AnyAuthenticationRequestParameters { get }

    func performChallenge(with parameters: ADYChallengeParameters, completionHandler: @escaping (AnyChallengeResult?, Error?) -> Void)
}

extension ADYTransaction: AnyADYTransaction {

    internal var authenticationParameters: AnyAuthenticationRequestParameters { authenticationRequestParameters }

    internal func performChallenge(with parameters: ADYChallengeParameters,
                                   completionHandler: @escaping (AnyChallengeResult?, Error?) -> Void) {
        performChallenge(with: parameters,
                         completionHandler: { (result: ADYChallengeResult?, error: Error?) -> Void in
                             completionHandler(result, error)
                         })
    }
}
