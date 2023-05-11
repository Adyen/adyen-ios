//
// Copyright (c) 2022 Adyen N.V.
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
    
    enum ShowRegistrationScreenMockState {
        case register
        case fallback
    }
    
    let showRegisterationReturnState: ShowRegistrationScreenMockState
    func showRegistrationScreen(component: Adyen.Component,
                                registerDelegatedAuthenticationHandler: @escaping () -> Void,
                                fallbackHandler: @escaping () -> Void) {
        switch showRegisterationReturnState {
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
    
    init(showRegisterationReturnState: ShowRegistrationScreenMockState,
         showApprovalScreenReturnState: ShowApprovalScreenMockState) {
        self.showRegisterationReturnState = showRegisterationReturnState
        self.showApprovalScreenReturnState = showApprovalScreenReturnState
    }
}

#endif
