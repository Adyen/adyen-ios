//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

internal enum ThreeDS2ActionHandlerError: Error {
    case cancellation(AdditionalDetails)
    case underlyingError(Error)
    case unknown(UnknownError)
    case missingTransaction
    
    init(error: ThreeDS2CoreActionHandlerError) {
        switch error {
        case let .cancellationAction(threeDSResult):
            self = .cancellation(ThreeDS2Details.challengeResult(threeDSResult))
        case .missingTransaction:
            self = .missingTransaction
        case let .unknown(unknownError):
            self = .unknown(unknownError)
        case let .underlyingError(underlyingError):
            self = .underlyingError(underlyingError)
        }
    }
}

/// :nodoc:
internal protocol AnyThreeDS2ActionHandler {

    /// :nodoc:
    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, ThreeDS2ActionHandlerError>) -> Void)

    /// :nodoc:
    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, ThreeDS2ActionHandlerError>) -> Void)
}

/// :nodoc:
internal protocol ComponentWrapper: Component {

    var wrappedComponent: Component { get }
    
}

/// :nodoc:
extension ComponentWrapper {

    /// :nodoc:
    internal var apiContext: APIContext { wrappedComponent.apiContext }

    /// :nodoc:
    internal var _isDropIn: Bool { // swiftlint:disable:this identifier_name
        get {
            wrappedComponent._isDropIn
        }

        set {
            wrappedComponent._isDropIn = newValue
        }
    }
}
