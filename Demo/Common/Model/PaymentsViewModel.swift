//
//  PaymentsViewModel.swift
//  Adyen
//
//  Created by Vladimir Abramichev on 05/02/2021.
//  Copyright © 2021 Adyen. All rights reserved.
//

import UIKit
import Adyen

open class ComponentsModel {

    private var paymentMethods: PaymentMethods?

    private lazy var dropInIntegration: DropInIntegrationController = {
        let controller = DropInIntegrationController()
        controller.presenter = presenter
        return controller
    }()

    private lazy var componentIntegration: ComponentIntegrationController = {
        let controller = ComponentIntegrationController()
        controller.presenter = presenter
        return controller
    }()

    internal weak var presenter: Presenter?

    internal lazy var items: [[ComponentItem]] = [
        [
            ComponentItem(title: "Drop In", present: dropInIntegration.DropIn)
        ],
        [
            ComponentItem(title: "Card", present: componentIntegration.Card),
            ComponentItem(title: "ApplePay", present: componentIntegration.ApplePay),
            ComponentItem(title: "iDEAL", present: componentIntegration.Ideal),
            ComponentItem(title: "SEPA Direct Debit", present: componentIntegration.SEPADirectDebit),
            ComponentItem(title: "MB WAY", present: componentIntegration.MBWay)
        ]
    ]

    // MARK: - Private

    private lazy var paymentMethodProvider: PaymentMethodsProvider = {
        if CommandLine.arguments.contains("-UITests") {
            return LocalPaymentMethodProvider()
        } else {
            return NetworkPaymentMethodsProvider()
        }
    }()

    internal func requestPaymentMethods() {
        paymentMethodProvider.request { (result) in
            switch result {
            case let .success(paymentMethods):
                self.dropInIntegration.paymentMethods = paymentMethods
                self.componentIntegration.paymentMethods = paymentMethods
            case let .failure(error):
                self.presenter?.presentAlert(with: error, retryHandler: self.requestPaymentMethods)
            }
        }
    }

}


