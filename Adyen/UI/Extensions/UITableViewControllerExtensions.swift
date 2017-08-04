//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension UITableViewController {
    
    /// Boolean value indicating whether an activity indicator should be shown.
    internal var showsActivityIndicatorView: Bool {
        get {
            return activityIndicatorView.superview != nil
        }
        
        set {
            if newValue {
                view.addSubview(activityIndicatorView)
                
                configureActivityIndicatorViewConstraints()
                
                activityIndicatorView.startAnimating()
            } else {
                activityIndicatorView.removeFromSuperview()
                activityIndicatorView.stopAnimating()
            }
        }
    }
    
    private var activityIndicatorView: UIActivityIndicatorView {
        if let activityIndicatorView = objc_getAssociatedObject(self, &AssociatedObjectKeys.activityIndicatorView) as? UIActivityIndicatorView {
            return activityIndicatorView
        }
        
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        objc_setAssociatedObject(self, &AssociatedObjectKeys.activityIndicatorView, activityIndicatorView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return activityIndicatorView
    }
    
    private func configureActivityIndicatorViewConstraints() {
        guard activityIndicatorView.constraints.isEmpty else {
            return
        }
        
        let constraints = [
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ]
        NSLayoutConstraint.activate(constraints)
    }
    
    private struct AssociatedObjectKeys {
        static var activityIndicatorView = "checkout_activityIndicatorView"
    }
    
}
