//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import AdyenUI
import Foundation
import SwiftUI
import UIKit

/// Callback protocol for document action views.
internal protocol DocumentActionViewDelegate: AnyObject {
    
    func didComplete()
    
    func mainButtonTap(sourceView: UIView, downloadable: Downloadable)
}

internal final class DocumentActionView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel, mainButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .center
        return stackView
    }()
    
    internal lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        imageView.adyen.round(using: .fixed(AdyenUIConstants.imageCornerRadius))
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    internal lazy var messageLabel: UILabel = {
        let label = AdyenLabel()
        label.apply(theme.elements.labels.body)
        label.textAlignment = .center
        label.text = viewModel.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.required, for: .vertical)
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "messageLabel")
        
        return label
    }()
    
    private lazy var mainButton: FormButton = {
        let button = FormButton(buttonStyle: theme.elements.buttons.tertiary, titleStyle: theme.elements.labels.bodyEmphasized)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = viewModel.buttonTitle
        button.addTarget(self, action: #selector(onMainButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "mainButton")
        button.preservesSuperviewLayoutMargins = true
        
        return button
    }()

    internal weak var delegate: DocumentActionViewDelegate?
    
    /// The view model.
    private let viewModel: DocumentActionViewModel
    
    private let imageLoader: ImageLoading
    private var imageLoadingTask: AdyenCancellable?
    
    /// The theme.
    private let theme: CheckoutTheme
    
    internal init(
        viewModel: DocumentActionViewModel,
        theme: CheckoutTheme,
        imageLoader: ImageLoading = ImageLoaderProvider.imageLoader()
    ) {
        self.viewModel = viewModel
        self.imageLoader = imageLoader
        self.theme = theme
        super.init(frame: .zero)
        configureViews()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        backgroundColor = theme.colors.background
        addSubview(stackView)
        stackView.adyen.anchor(inside: .view(self), edgeInsets: .init(left: 20, right: 20))
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -30)
        ])
        
    }
    
    @objc private func onMainButtonTap() {
        delegate?.mainButtonTap(sourceView: mainButton, downloadable: viewModel.action)
    }
    
    override public func didMoveToWindow() {
        super.didMoveToWindow()
        updateLogo()
    }
    
    private func updateLogo() {
        if window != nil {
            imageLoadingTask = imageView.load(url: viewModel.logoURL, using: imageLoader)
        } else {
            imageLoadingTask = nil
        }
    }
}
