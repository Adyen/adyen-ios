//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

protocol CheckoutStartDelegate: class {
    func startCheckout()
}

class CartViewController: CheckoutStatusViewController {
    
    // MARK: - CheckoutStatusViewController
    
    override func buttonClicked() {
        checkoutStartDelegate?.startCheckout()
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkoutStepImageView.image = UIImage(named: "checkout")
        nextStepButton.setTitle("CHECKOUT", for: .normal)
    }
    
    // MARK: - Public
    
    weak var checkoutStartDelegate: CheckoutStartDelegate?
    
}
