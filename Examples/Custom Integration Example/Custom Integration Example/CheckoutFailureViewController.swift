//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CheckoutFailureViewController: CheckoutStatusViewController {
    
    // MARK: - CheckoutStatusViewController
    
    override func buttonClicked() {
        navigationController?.popToRootViewController(animated: false)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkoutStepImageView.image = UIImage(named: "failure")
        nextStepButton.setTitle("TRY AGAIN", for: .normal)
    }
    
}
