//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

class CheckoutButton: UIButton {
    
    override var isEnabled: Bool {
        didSet {
            backgroundColor = backgroundColor?.withAlphaComponent(isEnabled ? 1 : 0.5)
        }
    }
    
    func startLoading() {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
        indicator.hidesWhenStopped = true
        indicator.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(indicator)
        addConstraints(indicator)
        
        setTitleColor(titleColor(for: .normal)?.withAlphaComponent(0), for: .normal)
        
        indicator.startAnimating()
    }
    
    private func addConstraints(_ indicator: UIActivityIndicatorView) {
        addConstraint(NSLayoutConstraint(
            item: indicator,
            attribute: .centerX,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerX,
            multiplier: 1,
            constant: 0
        ))
        
        addConstraint(NSLayoutConstraint(
            item: indicator,
            attribute: .centerY,
            relatedBy: .equal,
            toItem: self,
            attribute: .centerY,
            multiplier: 1,
            constant: 0
        ))
    }
}
