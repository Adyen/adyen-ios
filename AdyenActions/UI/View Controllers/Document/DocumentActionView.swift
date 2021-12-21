//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// Callback protocol for basic action views with completion and main button actions.
internal protocol ActionViewDelegate: AnyObject {
    
    func didComplete()
    
    func mainButtonTap(sourceView: UIView)
}

internal final class DocumentActionView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel, mainButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .center
        return stackView
    }()
    
    internal lazy var imageView: NetworkImageView = {
        let imageView = NetworkImageView()
        imageView.imageURL = viewModel.logoURL
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 52).isActive = true
        imageView.adyen.round(using: style.image.cornerRounding)
        imageView.contentMode = style.image.contentMode
        imageView.layer.masksToBounds = style.image.clipsToBounds
        imageView.layer.borderColor = style.image.borderColor?.cgColor
        imageView.layer.borderWidth = style.image.borderWidth
        imageView.backgroundColor = style.image.backgroundColor
        
        return imageView
    }()
    
    internal lazy var messageLabel: UILabel = {
        let label = UILabel(style: style.messageLabel)
        label.text = viewModel.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentHuggingPriority(.required, for: .vertical)
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "messageLabel")
        
        return label
    }()
    
    private lazy var mainButton: UIButton = {
        let button = UIButton(style: style.mainButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(viewModel.buttonTitle, for: .normal)
        button.addTarget(self, action: #selector(onMainButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "mainButton")
        button.preservesSuperviewLayoutMargins = true
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        return button
    }()

    internal weak var delegate: ActionViewDelegate?
    
    /// The view model.
    private let viewModel: DocumentActionViewModel
    
    /// The UI style.
    private let style: DocumentComponentStyle
    
    internal init(viewModel: DocumentActionViewModel, style: DocumentComponentStyle) {
        self.viewModel = viewModel
        self.style = style
        super.init(frame: .zero)
        configureViews()
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        backgroundColor = style.backgroundColor
        addSubview(stackView)
        stackView.adyen.anchor(inside: .view(self), edgeInsets: .init(left: 20, right: -20))
        NSLayoutConstraint.activate([stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
                                     stackView.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
                                     stackView.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor, constant: -30)])
        
    }
    
    @objc private func onMainButtonTap() {
        delegate?.mainButtonTap(sourceView: mainButton)
    }
}
