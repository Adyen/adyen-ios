//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Adyen3DS2
import Foundation

internal enum ThreeDS2ActionHandlerError: Error {
    case cancellation(AdditionalDetails)
    case underlyingError(Error)
    case unknown(UnknownError)
    case missingTransaction
    
    internal init(error: ThreeDS2CoreActionHandlerError) {
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

internal protocol AnyThreeDS2ActionHandler {

    func handle(_ fingerprintAction: ThreeDS2FingerprintAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, ThreeDS2ActionHandlerError>) -> Void)

    func handle(_ challengeAction: ThreeDS2ChallengeAction,
                completionHandler: @escaping (Result<ThreeDSActionHandlerResult, ThreeDS2ActionHandlerError>) -> Void)
    
    var threeDSRequestorAppURL: URL? { get set }
}

internal protocol ComponentWrapper: Component {

    var wrappedComponent: Component { get }
    
}

extension ComponentWrapper {

    internal var apiContext: APIContext { wrappedComponent.context.apiContext }

    internal var context: AdyenContext { wrappedComponent.context }

    internal var _isDropIn: Bool { // swiftlint:disable:this identifier_name
        get {
            wrappedComponent._isDropIn
        }

        set {
            wrappedComponent._isDropIn = newValue
        }
    }
}

internal func createDefaultThreeDS2CoreActionHandler(
    context: AdyenContext,
    appearanceConfiguration: ADYAppearanceConfiguration,
    delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication?
) -> AnyThreeDS2CoreActionHandler {
    #if canImport(AdyenAuthentication)
        if #available(iOS 14.0, *), let delegatedAuthenticationConfiguration = delegatedAuthenticationConfiguration {
            return ThreeDS2PlusDACoreActionHandler(context: context,
                                                   appearanceConfiguration: appearanceConfiguration,
                                                   delegatedAuthenticationConfiguration: delegatedAuthenticationConfiguration)
        } else {
            return ThreeDS2CoreActionHandler(context: context,
                                             appearanceConfiguration: appearanceConfiguration)
        }
    #else
        return ThreeDS2CoreActionHandler(context: context,
                                         appearanceConfiguration: appearanceConfiguration)
    #endif
}
