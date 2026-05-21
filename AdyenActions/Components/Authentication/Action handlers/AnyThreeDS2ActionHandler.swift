//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import protocol Adyen.Component

#if canImport(AdyenUI)
    import AdyenUI
#endif
import Foundation

internal protocol AnyThreeDS2ActionHandler {

    func handle(
        _ fingerprintAction: ThreeDS2FingerprintAction,
        completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void
    )

    func handle(
        _ challengeAction: ThreeDS2ChallengeAction,
        completionHandler: @escaping (Result<ThreeDSActionHandlerResult, Error>) -> Void
    )

    var threeDSRequestorAppURL: URL? { get set }

    var presentationDelegate: PresentationDelegate? { get set }
}

internal protocol ComponentWrapper: Component {

    var wrappedComponent: Component { get }

}

extension ComponentWrapper {

    internal var apiContext: APIContext {
        wrappedComponent.context.apiContext
    }

    internal var context: AdyenContext {
        wrappedComponent.context
    }

    internal var _isDropIn: Bool { // swiftlint:disable:this identifier_name
        get {
            wrappedComponent._isDropIn
        }

        set {
            wrappedComponent._isDropIn = newValue
        }
    }
}

@MainActor
internal func createDefaultThreeDS2CoreActionHandler(
    context: AdyenContext,
    service: ThreeDSService,
    theme: CheckoutTheme,
    delegatedAuthenticationConfiguration: AuthenticationConfiguration.DelegatedAuthentication?
) -> AnyThreeDS2CoreActionHandler {
    #if canImport(AdyenAuthentication)
        if let delegatedAuthenticationConfiguration {
            return ThreeDS2PlusDACoreActionHandler(
                context: context,
                service: service,
                theme: theme,
                delegatedAuthenticationConfiguration: delegatedAuthenticationConfiguration
            )
        } else {
            return ThreeDS2CoreActionHandler(
                context: context,
                service: service,
                theme: theme
            )
        }
    #else
        return ThreeDS2CoreActionHandler(
            context: context,
            service: service,
            theme: theme
        )
    #endif
}
