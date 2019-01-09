//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CheckoutViewController: UIViewController {
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        var frame = navigationBar.frame
        frame.size.width = view.bounds.width
        navigationBar.frame = frame
        view.addSubview(navigationBar)
        
    }
    
    // MARK: - Public
    
    let navigationBar = CheckoutFlowNavigationBar.bar(withTitle: "")
    
    @objc func close() {
        PaymentRequestManager.shared.cancelRequest()
        dismiss(animated: true, completion: nil)
    }
    
}
