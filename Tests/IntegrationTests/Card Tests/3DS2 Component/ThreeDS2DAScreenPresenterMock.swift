//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

#if canImport(AdyenAuthentication)
    @_spi(AdyenInternal) @testable import Adyen
    import Adyen3DS2
    @_spi(AdyenInternal) @testable import AdyenActions
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
            (number: String?, type: Adyen.CardType?)
        ) -> Void)?

        func showRegistrationScreen(
            component: any Adyen.Component,
            cardDetails: (number: String?, type: Adyen.CardType?),
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
            (number: String?, type: Adyen.CardType?),
            Adyen.Amount?
        ) -> Void)?
        
        func showApprovalScreen(
            component: any Adyen.Component,
            cardDetails: (number: String?, type: Adyen.CardType?),
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
