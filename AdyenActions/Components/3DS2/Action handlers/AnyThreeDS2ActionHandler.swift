//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// :nodoc:
protocol AnyThreeDS2ActionHandler {

    /// :nodoc:
    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void)

    /// :nodoc:
    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void)
}

/// :nodoc:
protocol ComponentWrapper: Component {

    var wrappedComponent: Component { get }
    
}

/// :nodoc:
extension ComponentWrapper {

    /// :nodoc:
    var apiContext: APIContext { wrappedComponent.apiContext }

    /// :nodoc:
    var _isDropIn: Bool { // swiftlint:disable:this identifier_name
        get {
            wrappedComponent._isDropIn
        }

        set {
            wrappedComponent._isDropIn = newValue
        }
    }
}
