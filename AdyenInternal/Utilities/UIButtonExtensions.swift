//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

public extension UIButton {
    /// Boolean value indicating whether an activity indicator should be shown.
    var showsActivityIndicator: Bool {
        get {
            return activityIndicatorView.superview != nil
        }
        
        set {
            if newValue {
                addSubview(activityIndicatorView)
                activityIndicatorView.startAnimating()
                
                addActivityIndicatorViewConstraints()
                
                titleLabel?.alpha = 0.0 // Use alpha to hide, since isHidden does not work.
            } else {
                activityIndicatorView.removeFromSuperview()
                activityIndicatorView.stopAnimating()
                
                removeActivityIndicatorViewConstraints()
                
                titleLabel?.alpha = 1.0 // Use alpha to hide, since isHidden does not work.
            }
        }
    }
    
    // MARK: - Activity Indicator View
    
    private var activityIndicatorView: UIActivityIndicatorView {
        if let activityIndicatorView = objc_getAssociatedObject(self, &AssociatedObjectKeys.activityIndicatorView) as? UIActivityIndicatorView {
            return activityIndicatorView
        }
        
        let activityIndicatorView = UIActivityIndicatorView(style: .white)
        activityIndicatorView.color = activityIndicatorViewColor
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        objc_setAssociatedObject(self, &AssociatedObjectKeys.activityIndicatorView, activityIndicatorView, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return activityIndicatorView
    }
    
    private var activityIndicatorViewColor: UIColor? {
        let foregroundColor = attributedTitle(for: .normal)?.attribute(.foregroundColor, at: 0, effectiveRange: nil) as? UIColor
        
        return foregroundColor ?? titleLabel?.textColor
    }
    
    // MARK: - Layout
    
    private func addActivityIndicatorViewConstraints() {
        guard activityIndicatorView.constraints.isEmpty else {
            return
        }
        
        let constraints = [
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func removeActivityIndicatorViewConstraints() {
        NSLayoutConstraint.deactivate(activityIndicatorView.constraints)
    }
    
    // MARK: - AssociatedObjectKeys
    
    private struct AssociatedObjectKeys {
        static var activityIndicatorView = "checkout_activityIndicatorView"
    }
    
}
