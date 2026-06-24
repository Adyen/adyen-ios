//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey
import Foundation
import LocalAuthentication
import UIKit

internal protocol ThreeDS2PlusDAScreenPresenterProtocol {
    func showRegistrationScreen(
        component: Component,
        cardDetails: (number: String?, brand: CardBrand?),
        registerDelegatedAuthenticationHandler: @escaping VoidHandler,
        fallbackHandler: @escaping VoidHandler
    )
    
    // swiftlint:disable function_parameter_count
    func showApprovalScreen(
        component: Component,
        cardDetails: (number: String?, brand: CardBrand?),
        amount: Amount?,
        approveAuthenticationHandler: @escaping VoidHandler,
        fallbackHandler: @escaping VoidHandler,
        removeCredentialsHandler: @escaping VoidHandler
    )
    // swiftlint:enable function_parameter_count
    
    func showAuthenticationError(
        component: Component,
        handler: @escaping VoidHandler,
        troubleshootingHandler: @escaping VoidHandler
    )
    
    func showRegistrationError(component: Component, handler: @escaping VoidHandler)
    func showDeletionConfirmation(component: Component, handler: @escaping VoidHandler)

    var presentationDelegate: PresentationDelegate? { get set }
}

/// This type handles the presenting of the Delegate authentication screens of Register and Approval.
@MainActor
internal final class ThreeDS2PlusDAScreenPresenter: ThreeDS2PlusDAScreenPresenterProtocol {
    private let style: DelegatedAuthenticationComponentStyle
    private let localizedParameters: LocalizationParameters?
    private let context: AdyenContext
    
    /// Delegates `PresentableComponent`'s presentation.
    internal weak var presentationDelegate: PresentationDelegate?
    
    internal init(
        style: DelegatedAuthenticationComponentStyle,
        localizedParameters: LocalizationParameters?,
        context: AdyenContext
    ) {
        self.style = style
        self.context = context
        self.localizedParameters = localizedParameters
    }
    
    internal func showAuthenticationError(
        component: Component,
        handler: @escaping VoidHandler,
        troubleshootingHandler: @escaping VoidHandler
    ) {
        let errorController = DAErrorViewController(
            style: style,
            screen: .authenticationFailed(localizationParameters: localizedParameters),
            completion: handler,
            troubleshootingHandler: troubleshootingHandler
        )
        presentationDelegate?.present(viewController: errorController)
    }
    
    internal func showRegistrationError(
        component: Component,
        handler: @escaping VoidHandler
    ) {
        let errorController = DAErrorViewController(
            style: style,
            screen: .registrationFailed(localizationParameters: localizedParameters),
            completion: handler,
            troubleshootingHandler: nil
        )
        presentationDelegate?.present(viewController: errorController)
    }
    
    internal func showDeletionConfirmation(component: Component, handler: @escaping VoidHandler) {
        let errorController = DAErrorViewController(
            style: style,
            screen: .deletionConfirmation(localizationParameters: localizedParameters),
            completion: handler,
            troubleshootingHandler: nil
        )
        presentationDelegate?.present(viewController: errorController)
    }

    internal func showRegistrationScreen(
        component: Component,
        cardDetails: (number: String?, brand: CardBrand?),
        registerDelegatedAuthenticationHandler: @escaping VoidHandler,
        fallbackHandler: @escaping VoidHandler
    ) {
        let registrationViewController = DARegistrationViewController(
            style: style,
            localizationParameters: localizedParameters,
            logoProvider: LogoURLProvider(environment: context.apiContext.environment),
            cardNumber: cardDetails.number,
            cardBrand: cardDetails.brand,
            biometricName: biometricName,
            enableCheckoutHandler: {
                registerDelegatedAuthenticationHandler()
            },
            notNowHandler: {
                fallbackHandler()
            }
        )
        presentationDelegate?.present(viewController: registrationViewController)
    }
    
    // swiftlint:disable function_parameter_count
    internal func showApprovalScreen(
        component: Component,
        cardDetails: (number: String?, brand: CardBrand?),
        amount: Amount?,
        approveAuthenticationHandler: @escaping VoidHandler,
        fallbackHandler: @escaping VoidHandler,
        removeCredentialsHandler: @escaping VoidHandler
    ) {
        // swiftlint:enable function_parameter_count
        let approvalViewController = DAApprovalViewController(
            style: style,
            localizationParameters: localizedParameters,
            logoProvider: LogoURLProvider(environment: context.apiContext.environment),
            amount: amount?.formatted,
            cardNumber: cardDetails.number,
            cardBrand: cardDetails.brand,
            useBiometricsHandler: {
                approveAuthenticationHandler()
            },
            approveDifferentlyHandler: {
                fallbackHandler()
            },
            removeCredentialsHandler: {
                removeCredentialsHandler()
            }
        )
        presentationDelegate?.present(viewController: approvalViewController)
    }
    
    private var biometricName: String {
        let authContext = LAContext()
        _ = authContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        switch authContext.biometryType {
        case .none:
            return localizedString(.threeds2DABiometrics, localizedParameters)
        case .touchID:
            return localizedString(.threeds2DATouchID, localizedParameters)
        case .faceID:
            return localizedString(.threeds2DAFaceID, localizedParameters)
        default:
            return localizedString(.threeds2DABiometrics, localizedParameters)
        }
    }
}
