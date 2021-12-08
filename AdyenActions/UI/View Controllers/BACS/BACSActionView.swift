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

internal final class BACSActionView: UIView {

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [imageView, messageLabel, mainButton])
        stackView.axis = .vertical
        stackView.spacing = 30
        stackView.alignment = .center
        return stackView
    }()
    
    // :nodoc:
    internal lazy var imageView: UIImageView = {
        var image = UIImage(named: viewModel.imageName)
        if image == nil {
            image = UIImage(named: viewModel.imageName, in: Bundle.actionsInternalResources, compatibleWith: nil)
        }
        let imageView = UIImageView(image: image)
        imageView.contentMode = .center
        imageView.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "icon")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        return imageView
    }()
    
    /// :nodoc:
    internal lazy var messageLabel: UILabel = {
        let label = UILabel(style: style.messageLabel)
        label.text = viewModel.message
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "messageLabel")
        
        return label
    }()
    
    private lazy var mainButton: SubmitButton = {
        let button = SubmitButton(style: style.mainButton)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.title = viewModel.buttonTitle
        button.addTarget(self, action: #selector(onMainButtonTap), for: .touchUpInside)
        button.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "mainButton")
        button.preservesSuperviewLayoutMargins = true
        button.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
        
        return button
    }()

    internal weak var delegate: ActionViewDelegate?
    
    /// The view model.
    private let viewModel: BACSActionViewModel
    
    /// The UI style.
    private let style: BACSActionComponentStyle
    
    internal init(viewModel: BACSActionViewModel, style: BACSActionComponentStyle) {
        self.viewModel = viewModel
        self.style = style
        super.init(frame: .zero)
    }
    
    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureViews() {
        stackView.adyen.anchor(inside: self)
        
    }
    
    @objc private func onMainButtonTap() {
        delegate?.mainButtonTap(sourceView: mainButton)
    }
}
