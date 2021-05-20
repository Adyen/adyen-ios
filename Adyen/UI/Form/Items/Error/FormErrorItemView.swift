//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing an error item.
internal final class FormErrorItemView: FormItemView<FormErrorItem> {

    /// Initializes the error item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormErrorItem) {
        super.init(item: item)
        bind(item.$message, to: messageLabel, at: \.text)
        bind(item.$message, to: self, at: \.accessibilityLabel)
        isHidden = item.isHidden.wrappedValue
        addSubview(containerView)
        containerView.adyen.anchor(inside: layoutMarginsGuide, with: UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16))
        containerView.backgroundColor = item.style.backgroundColor
        containerView.adyen.round(using: item.style.cornerRounding)
        backgroundColor = .clear
        preservesSuperviewLayoutMargins = true
        translatesAutoresizingMaskIntoConstraints = false

        isAccessibilityElement = true
        accessibilityLabel = item.message
        accessibilityTraits = messageLabel.accessibilityTraits
        accessibilityValue = messageLabel.accessibilityValue
    }

    // MARK: - Stack View

    private lazy var containerView: UIView = {
        let stackView = UIStackView(arrangedSubviews: [iconView, messageLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 16
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true

        return stackView.adyen.wrapped(with: UIEdgeInsets(top: 8, left: 16, bottom: -8, right: -16))
    }()

    // MARK: - Message

    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel(style: item.style.message)
        messageLabel.numberOfLines = 0
        messageLabel.isAccessibilityElement = false
        messageLabel.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "messageLabel")
        }
        messageLabel.translatesAutoresizingMaskIntoConstraints = false

        return messageLabel
    }()

    // MARK: - Icon

    private lazy var iconView: UIImageView = {
        let view = UIImageView(image: UIImage(named: item.iconName,
                                              in: Bundle.coreInternalResources,
                                              compatibleWith: nil))
        view.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "iconView")
        }
        view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            view.widthAnchor.constraint(equalToConstant: 12),
            view.heightAnchor.constraint(equalToConstant: 12)
        ])
        return view
    }()

}
