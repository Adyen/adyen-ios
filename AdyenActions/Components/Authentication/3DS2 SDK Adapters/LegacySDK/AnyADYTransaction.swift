//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen3DS2
import Foundation

@MainActor
internal protocol AnyADYTransaction {

    var authenticationParameters: AnyAuthenticationRequestParameters { get }

    func performChallenge(with parameters: ADYChallengeParameters, completionHandler: @escaping @MainActor (AnyChallengeResult?, Error?) -> Void)
}

extension ADYTransaction: @preconcurrency AnyADYTransaction {

    internal var authenticationParameters: AnyAuthenticationRequestParameters {
        authenticationRequestParameters
    }

    internal func performChallenge(
        with parameters: ADYChallengeParameters,
        completionHandler: @escaping @MainActor (AnyChallengeResult?, Error?) -> Void
    ) {
        performChallenge(
            with: parameters,
            completionHandler: { (result: ADYChallengeResult?, error: Error?) in
                // The 3DS2 SDK delivers its callbacks on the main thread.
                let delivery = ChallengeResultDelivery(
                    result: result,
                    error: error,
                    completionHandler: completionHandler
                )
                self.performSelector(
                    onMainThread: #selector(self.deliverChallengeResult(_:)),
                    with: delivery,
                    waitUntilDone: false
                )
            }
        )
    }

    @MainActor @objc private func deliverChallengeResult(_ delivery: ChallengeResultDelivery) {
        delivery.completionHandler(delivery.result, delivery.error)
    }
}

/// Carries the SDK challenge result across the `performSelector` hop,
/// whose `with:` parameter is not `Sendable`-checked.
private final class ChallengeResultDelivery: NSObject {

    internal let result: ADYChallengeResult?
    internal let error: Error?
    internal let completionHandler: @MainActor (AnyChallengeResult?, Error?) -> Void

    internal init(
        result: ADYChallengeResult?,
        error: Error?,
        completionHandler: @escaping @MainActor (AnyChallengeResult?, Error?) -> Void
    ) {
        self.result = result
        self.error = error
        self.completionHandler = completionHandler
    }
}
