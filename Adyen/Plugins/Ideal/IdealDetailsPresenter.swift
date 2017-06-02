//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

class IdealDetailsPresenter: PaymentMethodDetailsPresenter {
    private var hostViewController: UINavigationController?
    private var items: [InputSelectItem]
    
    var issuerPickerViewController: IdealIssuerPickerViewController?
    
    init(items: [InputSelectItem]) {
        self.items = items
    }
    
    func setup(with hostViewController: UIViewController, paymentRequest: PaymentRequest, paymentDetails: PaymentDetails, completion: @escaping (PaymentDetails) -> Void) {
        self.hostViewController = hostViewController as? UINavigationController
        
        issuerPickerViewController = IdealIssuerPickerViewController(items: items) { item in
            paymentDetails.fillIdeal(issuerIdentifier: item.identifier)
            completion(paymentDetails)
        }
    }
    
    func present() {
        if let viewController = issuerPickerViewController {
            hostViewController?.pushViewController(viewController, animated: true)
        }
    }
    
    func dismiss(animated: Bool, completion: @escaping () -> Void) {
        hostViewController?.popViewController(animated: true)
    }
}
