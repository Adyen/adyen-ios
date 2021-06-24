//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

internal final class AwaitView: UIView {
    
    /// :nodoc:
    internal lazy var icon: UIImageView = {
        var image = UIImage(named: viewModel.icon)
        if image == nil {
            image = UIImage(named: viewModel.icon, in: Bundle.actionsInternalResources, compatibleWith: nil)
        }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    /// :nodoc:
    internal lazy var messageLabel: UILabel = {
        let label = UILabel(style: style.message)
        label.text = viewModel.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "messageLabel")
        
        return label
    }()
    
    /// :nodoc:
    internal lazy var spinnerView: UIView = {
        let stackView = UIStackView(arrangedSubviews: [activityIndicatorView, spinnerTitleLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    /// :nodoc:
    internal lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.color = style.spinnerTitle.color
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
        return activityIndicatorView
    }()
    
    /// :nodoc:
    internal lazy var spinnerTitleLabel: UILabel = {
        let label = UILabel(style: style.spinnerTitle)
        label.text = viewModel.spinnerTitle
        label.numberOfLines = 1
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "spinnerTitleLabel")
        
        return label
    }()
    
    /// The view model.
    private let viewModel: AwaitComponentViewModel
    
    /// The UI style.
    private let style: AwaitComponentStyle
    
    /// Initializes the `AwaitView`.
    ///
    /// - Parameter viewModel: The view model.
    /// - Parameter style: The UI style.
    internal init(viewModel: AwaitComponentViewModel,
                  style: AwaitComponentStyle = AwaitComponentStyle()) {
        self.viewModel = viewModel
        self.style = style
        super.init(frame: .zero)
        addSubview(icon)
        addSubview(messageLabel)
        addSubview(spinnerView)
        configureConstraints()
        backgroundColor = style.backgroundColor
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    private func configureConstraints() {
        let constraints = [
            icon.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            icon.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            messageLabel.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 25),
            messageLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            messageLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            spinnerView.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16),
            spinnerView.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinnerView.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -32)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
