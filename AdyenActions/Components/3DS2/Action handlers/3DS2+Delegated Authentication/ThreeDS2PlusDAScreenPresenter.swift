//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen
import LocalAuthentication

internal protocol ThreeDS2PlusDAScreenPresenterProtocol {
    func showRegistrationScreen(component: Component,
                                cardDetails: (number: String?, type: CardType?),
                                registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                fallbackHandler: @escaping () -> Void)
    
    func showApprovalScreen(component: Component,
                            cardDetails: (number: String?, type: CardType?),
                            approveAuthenticationHandler: @escaping () -> Void,
                            fallbackHandler: @escaping () -> Void,
                            removeCredentialsHandler: @escaping () -> Void)
    
    func showAuthenticationError(component: Component, handler: @escaping () -> Void)
    func showRegistrationError(component: Component, handler: @escaping () -> Void)
    var presentationDelegate: PresentationDelegate? { get set }
}

/// This type handles the presenting of the Delegate authentication screens of Register and Approval.
@available(iOS 16.0, *)
internal final class ThreeDS2PlusDAScreenPresenter: ThreeDS2PlusDAScreenPresenterProtocol {
    /// Delegates `PresentableComponent`'s presentation.
    private let style: DelegatedAuthenticationComponentStyle
    private let localizedParameters: LocalizationParameters?
    private let context: AdyenContext
    internal weak var presentationDelegate: PresentationDelegate?
    
    internal init(style: DelegatedAuthenticationComponentStyle,
                  localizedParameters: LocalizationParameters?,
                  context: AdyenContext) {
        self.style = style
        self.context = context
        self.localizedParameters = localizedParameters
    }
    
    internal func showAuthenticationError(component: Component, handler: @escaping () -> Void) {
        AdyenAssertion.assert(message: "presentationDelegate should not be nil", condition: presentationDelegate == nil)
        let errorController = DAErrorViewController(style: style, 
                                                    screen: .authenticationFailed(localizationParameters: localizedParameters),
                                                    completion: handler)
        let presentableComponent = PresentableComponentWrapper(component: component,
                                                               viewController: errorController)
        presentationDelegate?.present(component: presentableComponent)
        errorController.navigationItem.rightBarButtonItems = []
        errorController.navigationItem.leftBarButtonItems = []
    }
    
    internal func showRegistrationError(component: Component, handler: @escaping () -> Void) {
        AdyenAssertion.assert(message: "presentationDelegate should not be nil", condition: presentationDelegate == nil)
        let errorController = DAErrorViewController(style: style, 
                                                    screen: .registrationFailed(localizationParameters: localizedParameters),
                                                    completion: handler)
        let presentableComponent = PresentableComponentWrapper(component: component,
                                                               viewController: errorController)
        presentationDelegate?.present(component: presentableComponent)
        errorController.navigationItem.rightBarButtonItems = []
        errorController.navigationItem.leftBarButtonItems = []
    }

    internal func showRegistrationScreen(component: Component,
                                         cardDetails: (number: String?, type: CardType?),
                                         registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                         fallbackHandler: @escaping () -> Void) {
        AdyenAssertion.assert(message: "presentationDelegate should not be nil", condition: presentationDelegate == nil)
        let registrationViewController = DARegistrationViewController(context: context,
                                                                      style: style,
                                                                      localizationParameters: localizedParameters,
                                                                      cardNumber: cardDetails.number,
                                                                      cardType: cardDetails.type,
                                                                      biometricName: biometricName,
                                                                      enableCheckoutHandler: {
                                                                          registerDelegatedAuthenticationHandler()
                                                                      }, notNowHandler: {
                                                                          fallbackHandler()
                                                                      })
        
        let presentableComponent = PresentableComponentWrapper(component: component,
                                                               viewController: registrationViewController)
        presentationDelegate?.present(component: presentableComponent)
        registrationViewController.navigationItem.rightBarButtonItems = []
        registrationViewController.navigationItem.leftBarButtonItems = []
    }
    
    internal func showApprovalScreen(component: Component,
                                     cardDetails: (number: String?, type: CardType?),
                                     approveAuthenticationHandler: @escaping () -> Void,
                                     fallbackHandler: @escaping () -> Void,
                                     removeCredentialsHandler: @escaping () -> Void) {
        AdyenAssertion.assert(message: "presentationDelegate should not be nil", condition: presentationDelegate == nil)
        let approvalViewController = DAApprovalViewController(context: context,
                                                              style: style,
                                                              localizationParameters: localizedParameters,
                                                              biometricName: biometricName,
                                                              amount: context.payment?.amount.formatted,
                                                              cardNumber: cardDetails.number,
                                                              cardType: cardDetails.type,
                                                              useBiometricsHandler: {
                                                                  approveAuthenticationHandler()
                                                              }, approveDifferentlyHandler: {
                                                                  fallbackHandler()
                                                              }, removeCredentialsHandler: {
                                                                  removeCredentialsHandler()
                                                              })
        
        let presentableComponent = PresentableComponentWrapper(component: component,
                                                               viewController: approvalViewController)
        presentationDelegate?.present(component: presentableComponent)
        approvalViewController.navigationItem.rightBarButtonItems = []
        approvalViewController.navigationItem.leftBarButtonItems = []
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
        case .opticID:
            return localizedString(.threeds2DAOpticID, localizedParameters)
        @unknown default:
            return localizedString(.threeds2DABiometrics, localizedParameters)
        }
    }
}
