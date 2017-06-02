//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class LoadingTableViewController: UITableViewController {
    private let loadingView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    fileprivate var _loading = false
    
    var loading: Bool {
        get {
            return _loading
        }
        
        set {
            _loading = newValue
            self.updateUI()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingView.isHidden = true
        loadingView.stopAnimating()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        applyLoadingViewConstraints()
    }
    
    func applyLoadingViewConstraints() {
        view.addSubview(loadingView)
        view.addConstraint(
            NSLayoutConstraint(
                item: loadingView,
                attribute: .centerX,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            )
        )
        view.addConstraint(
            NSLayoutConstraint(
                item: loadingView,
                attribute: .centerY,
                relatedBy: .equal,
                toItem: view,
                attribute: .centerY,
                multiplier: 1,
                constant: 0
            )
        )
    }
    
    func updateUI() {
        DispatchQueue.main.async {
            self.loadingView.isHidden = !self.loading
            self.loading ? self.loadingView.startAnimating() : self.loadingView.stopAnimating()
        }
    }
}
