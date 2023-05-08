//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal class LoadingViewController: UIViewController {
    
    override internal func loadView() {
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        
        if #available(iOS 13.0, *) {
            activityIndicator.color = .label
            activityIndicator.backgroundColor = .systemGroupedBackground.withAlphaComponent(0.7)
        } else {
            activityIndicator.backgroundColor = .black.withAlphaComponent(0.3)
        }
        
        activityIndicator.startAnimating()
        self.view = activityIndicator
    }
}
