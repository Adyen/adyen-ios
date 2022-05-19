//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Foundation

internal protocol AnyThreeDS2ActionHandler {

    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void)

    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void)
    
    var threeDSRequestorAppURL: URL? { get set }
}

internal protocol ComponentWrapper: Component {

    var wrappedComponent: Component { get }
    
}

extension ComponentWrapper {

    internal var apiContext: APIContext { wrappedComponent.apiContext }

    internal var _isDropIn: Bool { // swiftlint:disable:this identifier_name
        get {
            wrappedComponent._isDropIn
        }

        set {
            wrappedComponent._isDropIn = newValue
        }
    }
}
