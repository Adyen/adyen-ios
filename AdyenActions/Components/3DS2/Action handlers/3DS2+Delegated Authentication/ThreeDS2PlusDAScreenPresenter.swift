//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
@_spi(AdyenInternal) import Adyen

internal enum ThreeDS2PlusDAScreenUserInput {
    case approveDifferently
    case deleteDA
    case noInput
    case biometric
    
    internal var canShowRegistration: Bool {
        switch self {
        case .approveDifferently, .deleteDA, .biometric:
            return false
        case .noInput:
            return true
        }
    }
}

internal protocol ThreeDS2PlusDAScreenPresenterProtocol {
    func showRegistrationScreen(component: Component,
                                registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                fallbackHandler: @escaping () -> Void)
    
    func showApprovalScreen(component: Component,
                            approveAuthenticationHandler: @escaping () -> Void,
                            fallbackHandler: @escaping () -> Void,
                            removeCredentialsHandler: @escaping () -> Void)
    
    var userInput: ThreeDS2PlusDAScreenUserInput { get }
}

/// This type handles the presenting of the Delegate authentication screens of Register and Approval.
internal final class ThreeDS2PlusDAScreenPresenter: ThreeDS2PlusDAScreenPresenterProtocol {
    /// Delegates `PresentableComponent`'s presentation.
    internal weak var presentationDelegate: PresentationDelegate?
    private let style: DelegatedAuthenticationComponentStyle
    private let localizedParameters: LocalizationParameters?
    
    internal var userInput: ThreeDS2PlusDAScreenUserInput = .noInput

    internal init(presentationDelegate: PresentationDelegate?,
                  style: DelegatedAuthenticationComponentStyle,
                  localizedParameters: LocalizationParameters?) {
        self.presentationDelegate = presentationDelegate
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
                                                                  guard let self = self else { return }
                                                                  self.userInput = .biometric
                                                                  approveAuthenticationHandler()
                                                              }, approveDifferentlyHandler: { [weak self] in
                                                                  guard let self = self else { return }
                                                                  self.userInput = .approveDifferently
                                                                  fallbackHandler()
                                                              }, removeCredentialsHandler: { [weak self] in
                                                                  guard let self = self else { return }
                                                                  self.userInput = .deleteDA
                                                                  removeCredentialsHandler()
                                                              })
        
        let presentableComponent = PresentableComponentWrapper(component: component,
                                                               viewController: approvalViewController)
        presentationDelegate?.present(component: presentableComponent)
        approvalViewController.navigationItem.rightBarButtonItems = []
        approvalViewController.navigationItem.leftBarButtonItems = []
    }
}
