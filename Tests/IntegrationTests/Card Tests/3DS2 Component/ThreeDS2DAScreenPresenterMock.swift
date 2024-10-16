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
        func showDeletionConfirmation(component: any Adyen.Component, handler: @escaping () -> Void) {
            handler()
        }
        
        func showAuthenticationError(component: any Adyen.Component, handler: @escaping () -> Void) {
            handler()
        }
    
        func showRegistrationError(component: any Adyen.Component, handler: () -> Void) {
            handler()
        }
    
        var presentationDelegate: (any Adyen.PresentationDelegate)?
    
        enum ShowRegistrationScreenMockState {
            case register
            case fallback
        }
    
        let showRegistrationReturnState: ShowRegistrationScreenMockState
        func showRegistrationScreen(
            component: any Adyen.Component,
            cardDetails: (number: String?, type: Adyen.CardType?),
            registerDelegatedAuthenticationHandler: @escaping () -> Void,
            fallbackHandler: @escaping () -> Void
        ) {
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
    
        func showApprovalScreen(
            component: any Adyen.Component,
            cardDetails: (number: String?, type: Adyen.CardType?),
            approveAuthenticationHandler: @escaping () -> Void,
            fallbackHandler: @escaping () -> Void,
            removeCredentialsHandler: @escaping () -> Void
        ) {
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
