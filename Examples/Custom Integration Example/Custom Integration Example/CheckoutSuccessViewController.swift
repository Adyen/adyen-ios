//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CheckoutSuccessViewController: CheckoutStatusViewController {
    
    // MARK: - CheckoutStatusViewController
    
    override func buttonClicked() {
        navigationController?.popToRootViewController(animated: false)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkoutStepImageView.image = UIImage(named: "success")
        nextStepButton.setTitle("BACK TO SHOP", for: .normal)
    }
    
}
