//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Foundation
import UIKit

internal final class AwaitView: UIView {
    
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
    
    internal lazy var messageLabel: UILabel = {
        let label = UILabel(style: style.message)
        label.text = viewModel.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "messageLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
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
    
    internal lazy var activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .gray)
        activityIndicatorView.color = style.spinnerTitle.color
        activityIndicatorView.backgroundColor = .clear
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.startAnimating()
        
        return activityIndicatorView
    }()
    
    internal lazy var spinnerTitleLabel: UILabel = {
        let label = UILabel(style: style.spinnerTitle)
        label.text = viewModel.spinnerTitle
        label.numberOfLines = 1
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "spinnerTitleLabel")
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [icon, messageLabel, spinnerView])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    /// The view model.
    private let viewModel: AwaitComponentViewModel
    
    /// The UI style.
    private let style: AwaitComponentStyle
    
    /// Initializes the `AwaitView`.
    ///
    /// - Parameter viewModel: The view model.
    /// - Parameter style: The UI style.
    internal init(
        viewModel: AwaitComponentViewModel,
        style: AwaitComponentStyle = AwaitComponentStyle()
    ) {
        self.viewModel = viewModel
        self.style = style
        super.init(frame: .zero)
        addSubview(contentStackView)
        configureConstraints()
        backgroundColor = style.backgroundColor
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureConstraints() {
        let constraints = [
            contentStackView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 16),
            contentStackView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -16),
            contentStackView.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            contentStackView.bottomAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),
            messageLabel.widthAnchor.constraint(equalTo: contentStackView.widthAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
