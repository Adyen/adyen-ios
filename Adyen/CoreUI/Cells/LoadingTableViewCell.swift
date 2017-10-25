//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class LoadingTableViewCell: UITableViewCell {
    private let loadingIndicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    var isShowingLoadingIndicator: Bool {
        return loadingIndicator.isAnimating
    }
    
    func startLoadingAnimation() {
        DispatchQueue.main.async {
            self.accessoryView = self.loadingIndicator
            self.loadingIndicator.startAnimating()
        }
    }
    
    func stopLoadingAnimation() {
        DispatchQueue.main.async {
            self.loadingIndicator.stopAnimating()
        }
    }
}
