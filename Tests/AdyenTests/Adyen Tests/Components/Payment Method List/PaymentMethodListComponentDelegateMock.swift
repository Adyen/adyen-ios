//
//  PaymentMethodListComponentDelegateMock.swift
//  Adyen
//
//  Created by Mohamed Eldoheiri on 10/29/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

@testable import AdyenDropIn
import Foundation

internal final class PaymentMethodListComponentDelegateMock: PaymentMethodListComponentDelegate {

    var onDidLoad: ((_ paymentMethodListComponent: PaymentMethodListComponent) -> Void)?

    func didLoad(_ paymentMethodListComponent: PaymentMethodListComponent) {
        onDidLoad?(paymentMethodListComponent)
    }
    
    var onDidSelect: ((_ component: PaymentComponent, _ paymentMethodListComponent: PaymentMethodListComponent) -> Void)?
    
    func didSelect(_ component: PaymentComponent, in paymentMethodListComponent: PaymentMethodListComponent) {
        onDidSelect?(component, paymentMethodListComponent)
    }
    
    var onDidDelete: ((_ paymentMethod: StoredPaymentMethod, _ paymentMethodListComponent: PaymentMethodListComponent, _ completion: @escaping Completion<Bool>) -> Void)?
    
    func didDelete(_ paymentMethod: StoredPaymentMethod, in paymentMethodListComponent: PaymentMethodListComponent, completion: @escaping Completion<Bool>) {
        onDidDelete?(paymentMethod, paymentMethodListComponent, completion)
    }
    
}
