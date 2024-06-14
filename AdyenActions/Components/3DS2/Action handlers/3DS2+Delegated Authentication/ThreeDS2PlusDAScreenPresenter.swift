//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen

internal protocol ThreeDS2PlusDAScreenPresenterProtocol {
    func showRegistrationScreen(component: Component,
                                registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                fallbackHandler: @escaping () -> Void)
    
    func showApprovalScreen(component: Component,
                            approveAuthenticationHandler: @escaping () -> Void,
                            fallbackHandler: @escaping () -> Void,
                            removeCredentialsHandler: @escaping () -> Void)
    
    var presentationDelegate: PresentationDelegate? { get set }
}

/// This type handles the presenting of the Delegate authentication screens of Register and Approval.
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
                                         registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                         fallbackHandler: @escaping () -> Void) {
        AdyenAssertion.assert(message: "presentationDelegate should not be nil", condition: presentationDelegate == nil)
        let registrationViewController = DARegistrationViewController(style: style,
                                                                      localizationParameters: localizedParameters,
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
                                                              useBiometricsHandler: { [weak self] in
                                                                  guard let self else { return }
                                                                  approveAuthenticationHandler()
                                                              }, approveDifferentlyHandler: { [weak self] in
                                                                  guard let self else { return }
                                                                  fallbackHandler()
                                                              }, removeCredentialsHandler: { [weak self] in
                                                                  guard let self else { return }
                                                                  removeCredentialsHandler()
                                                              })
        
        let presentableComponent = PresentableComponentWrapper(component: component,
                                                               viewController: approvalViewController)
        presentationDelegate?.present(component: presentableComponent)
        approvalViewController.navigationItem.rightBarButtonItems = []
        approvalViewController.navigationItem.leftBarButtonItems = []
    }
}
