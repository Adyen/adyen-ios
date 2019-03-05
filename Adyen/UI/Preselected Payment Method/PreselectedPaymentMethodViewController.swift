//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

internal class PreselectedPaymentMethodViewController: ShortViewController {
    
    // MARK: - Lifecycle
    
    init(paymentMethod: PaymentMethod) {
        self.paymentMethod = paymentMethod
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    let paymentMethod: PaymentMethod
    
    var payButtonTitle = "" {
        didSet {
            preselectedPaymentMethodView.payButton.setTitle(payButtonTitle, for: [])
        }
    }
    
    internal var changeButtonHandler: (() -> Void)? {
        didSet {
            configureChangeButton()
        }
    }
    
    internal var payButtonHandler: (() -> Void)?
    
    // MARK: - UIViewController
    
    private var preselectedPaymentMethodView: PreselectedPaymentMethodView {
        return view as! PreselectedPaymentMethodView // swiftlint:disable:this force_cast
    }
    
    override func loadView() {
        view = PreselectedPaymentMethodView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = preselectedPaymentMethodView
        view.paymentMethodView.imageURL = paymentMethod.logoURL
        view.paymentMethodView.title = paymentMethod.displayName
        view.paymentMethodView.accessibilityLabel = ADYLocalizedString("preselectedPaymentMethod.accessibilityLabel", paymentMethod.accessibilityLabel)
        view.payButton.addTarget(self, action: #selector(didSelectPay), for: .touchUpInside)
    }
    
    // MARK: - Private
    
    private func configureChangeButton() {
        if changeButtonHandler == nil {
            navigationItem.rightBarButtonItem = nil
        } else {
            let changeButtonItem = UIBarButtonItem(title: ADYLocalizedString("preselectedPaymentMethod.changeButton.title"),
                                                   style: .done,
                                                   target: self,
                                                   action: #selector(didSelectChange))
            changeButtonItem.accessibilityIdentifier = "change-payment-method-button"
            changeButtonItem.accessibilityLabel = ADYLocalizedString("preselectedPaymentMethod.changeButton.accessibilityLabel")
            navigationItem.rightBarButtonItem = changeButtonItem
        }
    }
    
    @objc private func didSelectChange() {
        changeButtonHandler?()
    }
    
    @objc private func didSelectPay() {
        payButtonHandler?()
    }
    
}

extension PreselectedPaymentMethodViewController: PaymentProcessingElement {
    func startProcessing() {
        preselectedPaymentMethodView.payButton.showsActivityIndicator = true
    }
    
    func stopProcessing() {
        preselectedPaymentMethodView.payButton.showsActivityIndicator = false
    }
}
