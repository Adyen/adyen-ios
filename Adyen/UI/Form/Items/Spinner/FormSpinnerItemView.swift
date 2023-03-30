//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing an activity indicator view (spinner).
internal final class FormSpinnerItemView: FormItemView<FormSpinnerItem> {
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: activityIndicatorStyle)
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.accessibilityIdentifier = item.identifier.map
            { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "spinner") }
        return activityIndicatorView
    }()
    
    private var activityIndicatorStyle: UIActivityIndicatorView.Style {
        if #available(iOS 13.0, *) {
            return .large
        } else {
            return .whiteLarge
        }
    }
    
    /// Initializes the spinner item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormSpinnerItem) {
        super.init(item: item)
        
        addSubview(activityIndicatorView)
        activityIndicatorView.adyen.anchor(inside: self)

        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        
        observe(item.$isAnimating) { [weak self] isAnimating in
            if isAnimating {
                self?.activityIndicatorView.startAnimating()
            } else {
                self?.activityIndicatorView.stopAnimating()
            }
        }
    }
}
