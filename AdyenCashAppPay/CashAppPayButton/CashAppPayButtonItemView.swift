//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import PayKitUI
import UIKit

/// A view representing a Cash App Pay button view.
@available(iOS 13.0, *)
internal final class CashAppPayButtonItemView: FormItemView<CashAppPayButtonItem> {
    
    internal required init(item: CashAppPayButtonItem) {
        super.init(item: item)
        
        bind(item.$showsActivityIndicator, to: self, at: \.showsActivityIndicator)
        
        addSubview(button)
        addSubview(activityIndicatorView)
        
        button.adyen.anchor(inside: self.layoutMarginsGuide)
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    internal lazy var button: CashAppPayButton = {
        let button = CashAppPayButton { [weak self] in
            self?.item.selectionHandler()
        }
        
        button.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "button")
        }
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
    }()
    
    private lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .medium)
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()
    
    /// Boolean value indicating whether an activity indicator should be shown.
    internal var showsActivityIndicator: Bool {
        get {
            activityIndicatorView.isAnimating
        }
        
        set {
            if newValue {
                activityIndicatorView.startAnimating()
                button.alpha = 0.0
            } else {
                activityIndicatorView.stopAnimating()
                button.alpha = 1.0
            }
        }
    }
    
}
