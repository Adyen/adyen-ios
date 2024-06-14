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
                                cardNumber: String,
                                cardType: CardType,
                                context: AdyenContext,
                                registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                fallbackHandler: @escaping () -> Void)
    
    func showApprovalScreen(component: Component,
                            approveAuthenticationHandler: @escaping () -> Void,
                            fallbackHandler: @escaping () -> Void,
                            removeCredentialsHandler: @escaping () -> Void)
    
    var presentationDelegate: PresentationDelegate? { get set }
}

/// This type handles the presenting of the Delegate authentication screens of Register and Approval.
@available(iOS 16.0, *)
internal final class ThreeDS2PlusDAScreenPresenter: ThreeDS2PlusDAScreenPresenterProtocol {
    /// Delegates `PresentableComponent`'s presentation.
    private let style: DelegatedAuthenticationComponentStyle
    private let localizedParameters: LocalizationParameters?
        
    internal weak var presentationDelegate: PresentationDelegate?
    
    internal init(style: DelegatedAuthenticationComponentStyle,
                  localizedParameters: LocalizationParameters?) {
        self.style = style
        self.localizedParameters = localizedParameters
    }
    
    internal func showRegistrationScreen(component: Component,
                                         cardNumber: String,
                                         cardType: CardType,
                                         context: AdyenContext,
                                         registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                         fallbackHandler: @escaping () -> Void) {
        AdyenAssertion.assert(message: "presentationDelegate should not be nil", condition: presentationDelegate == nil)
        let registrationViewController = DARegistrationViewController(context: context,
                                                                      style: style,
                                                                      localizationParameters: localizedParameters,
                                                                      cardNumber: cardNumber,
                                                                      cardType: cardType,
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
                                     approveAuthenticationHandler: @escaping () -> Void,
                                     fallbackHandler: @escaping () -> Void,
                                     removeCredentialsHandler: @escaping () -> Void) {
        AdyenAssertion.assert(message: "presentationDelegate should not be nil", condition: presentationDelegate == nil)
        let approvalViewController = DAApprovalViewController(style: style,
                                                              localizationParameters: localizedParameters,
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
