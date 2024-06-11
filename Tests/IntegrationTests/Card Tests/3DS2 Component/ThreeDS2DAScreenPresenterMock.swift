//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

#if canImport(AdyenAuthentication)
    @_spi(AdyenInternal) @testable import Adyen
    import Adyen3DS2
    import AdyenAuthentication
    import Foundation
    import UIKit

    final class ThreeDS2DAScreenPresenterMock: ThreeDS2PlusDAScreenPresenterProtocol {
        var presentationDelegate: (any Adyen.PresentationDelegate)?
    
        enum ShowRegistrationScreenMockState {
            case register
            case fallback
        }
    
        let showRegistrationReturnState: ShowRegistrationScreenMockState
        func showRegistrationScreen(component: Adyen.Component,
                                    registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                    fallbackHandler: @escaping () -> Void) {
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

        func showApprovalScreen(component: Adyen.Component,
                                approveAuthenticationHandler: @escaping () -> Void,
                                fallbackHandler: @escaping () -> Void,
                                removeCredentialsHandler: @escaping () -> Void) {
            switch showApprovalScreenReturnState {
            case .approve:
                approveAuthenticationHandler()
            case .fallback:
                fallbackHandler()
            case .removeCredentials:
                removeCredentialsHandler()
            }
        }
    
        var userInput: ThreeDS2PlusDAScreenUserInput = .noInput
    
        init(showRegistrationReturnState: ShowRegistrationScreenMockState,
             showApprovalScreenReturnState: ShowApprovalScreenMockState,
             userInput: ThreeDS2PlusDAScreenUserInput = .noInput) {
            self.showRegistrationReturnState = showRegistrationReturnState
            self.showApprovalScreenReturnState = showApprovalScreenReturnState
            self.userInput = userInput
        }
    }

#endif
