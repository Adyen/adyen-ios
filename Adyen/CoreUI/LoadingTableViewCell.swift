//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    func startLoadingAnimation() {
        DispatchQueue.main.async {
            self.accessoryView = self.loadingIndicator
            self.loadingIndicator.startAnimating()
        }
    }
    
    func stopLoadingAnimation() {
        DispatchQueue.main.async {
            if let indicator = self.accessoryView as? UIActivityIndicatorView {
                indicator.stopAnimating()
            }
        }
    }
}
