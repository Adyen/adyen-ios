//
//  ReadyToSubmitPaymentComponentDelegateMock.swift
//  AdyenDropIn
//
//  Created by Mohamed Eldoheiri on 4/22/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Foundation
@testable import Adyen

final class ReadyToSubmitPaymentComponentDelegateMock: ReadyToSubmitPaymentComponentDelegate {
    var onShowConfirmation: ((ReadyToSubmitPaymentComponent) -> Void)?

    func showConfirmation(for component: ReadyToSubmitPaymentComponent) {
        onShowConfirmation?(component)
    }
}
