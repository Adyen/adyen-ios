//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenDropIn
import Foundation

internal final class PaymentMethodListComponentDelegateMock: PaymentMethodListComponentDelegate {

    var onDidLoad: ((_ paymentMethodListComponent: NewPaymentMethodListViewController) -> Void)?

    func didLoad(_ paymentMethodListComponent: NewPaymentMethodListViewController) {
        onDidLoad?(paymentMethodListComponent)
    }
    
    var onDidSelect: ((_ component: PaymentComponent, _ paymentMethodListComponent: NewPaymentMethodListViewController) -> Void)?
    
    func didSelect(_ component: PaymentComponent, in paymentMethodListComponent: NewPaymentMethodListViewController) {
        onDidSelect?(component, paymentMethodListComponent)
    }
    
    var onDidDelete: ((_ paymentMethod: StoredPaymentMethod, _ paymentMethodListComponent: NewPaymentMethodListViewController, _ completion: @escaping Completion<Bool>) -> Void)?
    
    func didDelete(_ paymentMethod: StoredPaymentMethod, in paymentMethodListComponent: NewPaymentMethodListViewController, completion: @escaping Completion<Bool>) {
        onDidDelete?(paymentMethod, paymentMethodListComponent, completion)
    }
    
}
