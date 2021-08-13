//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

internal final class ModalToolbar: UIView, AnyNavigationBar {
    private let style: NavigationStyle
    internal var onCancelHandler: (() -> Void)?
    private let title: String?
    private let paddingWithMarginCorrection: CGFloat = 16

    internal init(title: String?, style: NavigationStyle) {
        self.style = style
        self.title = title
        super.init(frame: .zero)

        setupView()
    }

    @available(*, unavailable)
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View Elements

    internal lazy var titleLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textAlignment = style.barTitle.textAlignment
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = title ?? ""
        return label
    }()

    internal lazy var cancelButton: UIButton = {
        let button = createCancelButton()
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        return button
    }()

    internal lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, cancelButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = 16
        stack.semanticContentAttribute = stackViewSemanticAttribute
        stack.layoutMargins = .init(top: 0, left: paddingWithMarginCorrection, bottom: 0, right: paddingWithMarginCorrection)
        stack.isLayoutMarginsRelativeArrangement = true

        return stack
    }()

    private var stackViewSemanticAttribute: UISemanticContentAttribute {
        switch style.toolbarMode {
        case .natural:
            return .unspecified
        case .leftCancel:
            return .forceRightToLeft
        case .rightCancel:
            return .forceLeftToRight
        }
    }

    @objc private func didCancel() {
        onCancelHandler?()
    }

    // MARK: - View setup

    private func setupView() {
        switch style.barTitle.textAlignment {
        case .center:
            addSubview(titleLabel)
            addSubview(cancelButton)
            setupLayoutForCenteredMode()
        default:
            addSubview(stackView)
            stackView.adyen.anchor(inside: self)
        }

        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = style.backgroundColor
        cancelButton.tintColor = style.tintColor
        guard let title = titleLabel.text, !title.isEmpty else { return }
        titleLabel.attributedText = NSAttributedString(string: title,
                                                       attributes: [NSAttributedString.Key.font: style.barTitle.font,
                                                                    NSAttributedString.Key.foregroundColor: style.barTitle.color,
                                                                    NSAttributedString.Key.backgroundColor: style.barTitle.backgroundColor])
    }

    private func setupLayoutForCenteredMode() {
        let titleLeadingAnchor = style.toolbarMode == .natural ? titleLabel.leadingAnchor : titleLabel.leftAnchor
        let titleTrailingAnchor = style.toolbarMode == .natural ? titleLabel.trailingAnchor : titleLabel.rightAnchor

        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            self.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            safeAreaLeadingAnchor.constraint(equalTo: titleLeadingAnchor, constant: -paddingWithMarginCorrection),
            safeAreaTrailingAnchor.constraint(equalTo: titleTrailingAnchor, constant: paddingWithMarginCorrection),
            
            self.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            self.heightAnchor.constraint(greaterThanOrEqualTo: cancelButton.heightAnchor),
            cancelPositionConstraint
        ])
    }

    private lazy var safeAreaLeadingAnchor: NSLayoutXAxisAnchor = {
        style.toolbarMode == .natural ? safeAreaLayoutGuide.leadingAnchor : safeAreaLayoutGuide.leftAnchor
    }()

    private lazy var safeAreaTrailingAnchor: NSLayoutXAxisAnchor = {
        style.toolbarMode == .natural ? safeAreaLayoutGuide.trailingAnchor : safeAreaLayoutGuide.rightAnchor
    }()

    private lazy var cancelPositionConstraint: NSLayoutConstraint = {
        let cancelPositionConstraint: NSLayoutConstraint

        switch style.toolbarMode {
        case .rightCancel:
            cancelPositionConstraint = rightAnchor.constraint(equalTo: cancelButton.rightAnchor,
                                                              constant: paddingWithMarginCorrection)
        case .leftCancel:
            cancelPositionConstraint = leftAnchor.constraint(equalTo: cancelButton.leftAnchor,
                                                             constant: -paddingWithMarginCorrection)
        case .natural:
            cancelPositionConstraint = trailingAnchor.constraint(equalTo: cancelButton.trailingAnchor,
                                                                 constant: paddingWithMarginCorrection)
        }

        return cancelPositionConstraint
    }()

    // MARK: - Private methods

    private func createCancelButton() -> UIButton {
        let button: UIButton

        func legacy() -> UIButton {
            let button = UIButton(type: UIButton.ButtonType.system)
            let cancelText = Bundle(for: UIApplication.self).localizedString(forKey: "Cancel", value: nil, table: nil)
            button.setTitle(cancelText, for: .normal)
            button.setTitleColor(style.tintColor, for: .normal)
            return button
        }

        switch style.cancelButton {
        case .legacy:
            return legacy()
        case let .custom(image):
            button = UIButton(type: UIButton.ButtonType.custom)
            button.setImage(image, for: .normal)
        default:
            if #available(iOS 13.0, *) {
                button = UIButton(type: UIButton.ButtonType.close)
                button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
            } else {
                return legacy()
            }
        }

        return button
    }
}
