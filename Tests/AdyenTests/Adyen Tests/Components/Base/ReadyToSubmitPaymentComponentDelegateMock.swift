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
    var onShowConfirmation: ((InstantPaymentComponent, PartialPaymentOrder?) -> Void)?

    func showConfirmation(for component: InstantPaymentComponent, with order: PartialPaymentOrder?) {
        onShowConfirmation?(component, order)
    }
}
