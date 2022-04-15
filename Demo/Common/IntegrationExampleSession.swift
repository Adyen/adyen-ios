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

extension IntegrationExample {}

extension IntegrationExample: AdyenSessionDelegate {
    
    func didComplete(with resultCode: SessionPaymentResultCode, component: Component, session: AdyenSession) {
        finish(with: resultCode)
    }
    
    func didFail(with error: Error, from component: Component, session: AdyenSession) {
        finish(with: error)
    }
    
    func didOpenExternalApplication(_ component: ActionComponent, session: AdyenSession) {}
    
    private func finish(with resultCode: SessionPaymentResultCode) {
        let resultCode = PaymentsResponse.ResultCode(rawValue: resultCode.rawValue) ?? .authorised
        finish(with: resultCode)
    }
    
}
