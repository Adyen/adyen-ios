//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A view representing an error item.
internal final class FormErrorItemView: FormItemView<FormErrorItem>, Observer {

    /// Initializes the error item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormErrorItem) {
        super.init(item: item)
        bind(item.$message, to: messageLabel, at: \.text)
        bind(item.$message, to: self, at: \.accessibilityLabel)
        observe(item.isHidden) { [weak self] isHidden in
            self?.updateVisibility(isHidden: isHidden)
        }
        isHidden = item.isHidden.wrappedValue
        addSubview(containerView)
        containerView.adyen.anchor(inside: safeAreaLayoutGuide, with: UIEdgeInsets(top: 16, left: 16, bottom: -16, right: -16))
        containerView.backgroundColor = item.style.backgroundColor
        containerView.adyen.round(using: item.style.cornerRounding)
        backgroundColor = .clear

        isAccessibilityElement = true
        accessibilityLabel = item.message
        accessibilityTraits = messageLabel.accessibilityTraits
        accessibilityValue = messageLabel.accessibilityValue
    }

    private func updateVisibility(isHidden: Bool) {
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            self?.isHidden = isHidden
        }, completion: { [weak self] _ in
            self?.adyen.updatePreferredContentSize()
        })
    }

    // MARK: - Stack View

    private lazy var containerView: UIView = {
        let stackView = UIStackView(arrangedSubviews: [iconView, messageLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 16
        stackView.isUserInteractionEnabled = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView.adyen.wrapped(with: UIEdgeInsets(top: 8, left: 16, bottom: -8, right: -16))
    }()

    // MARK: - Message

    private lazy var messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.font = item.style.message.font
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = item.style.message.color
        messageLabel.textAlignment = item.style.message.textAlignment
        messageLabel.backgroundColor = item.style.message.backgroundColor
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
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

}
