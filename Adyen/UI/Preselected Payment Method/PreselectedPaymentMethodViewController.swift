//
// Copyright (c) 2018 Adyen B.V.
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
            payButton.setTitle(payButtonTitle, for: [])
        }
    }
    
    var logoURL: URL? {
        didSet {
            paymentMethodView.imageURL = logoURL
        }
    }
    
    internal var changeButtonHandler: (() -> Void)? {
        didSet {
            configureChangeButton()
        }
    }
    
    internal var payButtonHandler: (() -> Void)?
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        edgesForExtendedLayout = []
        
        configureChangeButton()
        
        let margin: CGFloat = 16.0
        
        paymentMethodView.title = paymentMethod.displayName
        paymentMethodView.frame = CGRect(x: margin, y: 0, width: view.bounds.width - 2 * margin, height: 90)
        paymentMethodView.autoresizingMask = [.flexibleWidth]
        
        view.addSubview(paymentMethodView)
        
        payButton.sizeToFit()
        var frame = payButton.frame
        frame.origin = CGPoint(x: margin, y: paymentMethodView.frame.maxY)
        frame.size.width = view.bounds.width - 2 * margin
        payButton.frame = frame
        payButton.autoresizingMask = [.flexibleWidth]
        view.addSubview(payButton)
    }
    
    // MARK: - Private
    
    private lazy var paymentMethodView: ListItemView = {
        let listItemView = ListItemView()
        listItemView.titleAttributes = Appearance.shared.textAttributes
        listItemView.isAccessibilityElement = true
        listItemView.accessibilityLabel = ADYLocalizedString("preselectedPaymentMethod.accessibilityLabel", paymentMethod.accessibilityLabel)
        
        return listItemView
    }()
    
    private lazy var payButton: UIButton = {
        let payButton = Appearance.shared.payButton
        payButton.addTarget(self, action: #selector(didSelectPay), for: .touchUpInside)
        
        return payButton
    }()
    
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
        payButton.showsActivityIndicator = true
    }
    
    func stopProcessing() {
        payButton.showsActivityIndicator = false
    }
}
