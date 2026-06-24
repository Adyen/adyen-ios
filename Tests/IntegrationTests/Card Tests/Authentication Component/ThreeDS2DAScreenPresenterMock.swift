//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

#if canImport(AdyenAuthentication)
    @testable import Adyen
    @testable import AdyenActions
    import AdyenAuthentication
    import Foundation
    import UIKit

    final class ThreeDS2DAScreenPresenterMock: ThreeDS2PlusDAScreenPresenterProtocol {
    
        func showDeletionConfirmation(component: any Adyen.Component, handler: @escaping VoidHandler) {
            handler()
        }
        
        func showAuthenticationError(
            component: any Adyen.Component,
            handler: @escaping VoidHandler,
            troubleshootingHandler: @escaping VoidHandler
        ) {
            handler()
        }
    
        func showRegistrationError(component: any Adyen.Component, handler: VoidHandler) {
            handler()
        }
    
        var presentationDelegate: (any Adyen.PresentationDelegate)?
    
        enum ShowRegistrationScreenMockState {
            case register
            case fallback
        }
    
        let showRegistrationReturnState: ShowRegistrationScreenMockState
        var onShowRegistrationScreen: ((
            (number: String?, brand: Adyen.CardBrand?)
        ) -> Void)?

        func showRegistrationScreen(
            component: any Adyen.Component,
            cardDetails: (number: String?, brand: Adyen.CardBrand?),
            registerDelegatedAuthenticationHandler: @escaping VoidHandler,
            fallbackHandler: @escaping VoidHandler
        ) {
            onShowRegistrationScreen?(cardDetails)
            switch showRegistrationReturnState {
            case .register:
                registerDelegatedAuthenticationHandler()
            case .fallback:
                fallbackHandler()
            }
        }
    
        enum ShowApprovalScreenMockState {
            case approve
            case fallback
            case removeCredentials
        }
    
        let showApprovalScreenReturnState: ShowApprovalScreenMockState
    
        var onShowApprovalScreen: ((
            (number: String?, brand: Adyen.CardBrand?),
            Adyen.Amount?
        ) -> Void)?
        
        func showApprovalScreen(
            component: any Adyen.Component,
            cardDetails: (number: String?, brand: Adyen.CardBrand?),
            amount: Adyen.Amount?,
            approveAuthenticationHandler: @escaping VoidHandler,
            fallbackHandler: @escaping VoidHandler,
            removeCredentialsHandler: @escaping VoidHandler
        ) {
            onShowApprovalScreen?(cardDetails, amount)
            switch showApprovalScreenReturnState {
            case .approve:
                approveAuthenticationHandler()
            case .fallback:
                fallbackHandler()
            case .removeCredentials:
                removeCredentialsHandler()
            }
        }
    
        init(
            showRegistrationReturnState: ShowRegistrationScreenMockState,
            showApprovalScreenReturnState: ShowApprovalScreenMockState
        ) {
            self.showRegistrationReturnState = showRegistrationReturnState
            self.showApprovalScreenReturnState = showApprovalScreenReturnState
        }
    }

#endif
