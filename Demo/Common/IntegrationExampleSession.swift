//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenActions
import AdyenCard
import AdyenComponents
import AdyenDropIn
import AdyenNetworking
import AdyenSession
import UIKit

extension IntegrationExample: AdyenSessionDelegate {
    
    func didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession) {
        setupSession()
        dismissAndShowAlert(resultCode.isSuccess, resultCode.rawValue)
    }
    
    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        setupSession()
        dismissAndShowAlert(false, error.localizedDescription)
    }
    
    func didOpenExternalApplication(component: ActionComponent, session: AdyenSession) {}

}

extension SessionPaymentResultCode {
    var isSuccess: Bool {
        self == .authorised || self == .received || self == .pending
    }
}
