//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public class ModalToolbar: UIView, AnyNavigationBar {
    private enum Constants {
        static let titleButtonSpacing: CGFloat = 16
        static let titleVerticalPadding: CGFloat = 16
        static let largestSingleLineContentSize: UIContentSizeCategory = .large
    }

    private let style: NavigationStyle
    public var onCancelHandler: (() -> Void)?
    private let title: String?
    private let paddingWithMarginCorrection: CGFloat = 16

    public init(title: String?, style: NavigationStyle) {
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
        label.accessibilityTraits.insert(.header)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    internal lazy var cancelButton: UIButton = {
        let button = createCancelButton()
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .vertical)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        button.accessibilityLabel = Bundle(for: UIApplication.self).localizedString(forKey: "Cancel", value: nil, table: nil)
        return button
    }()

    internal lazy var stackView: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [titleLabel, cancelButton])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .center
        stack.distribution = .fill
        stack.axis = .horizontal
        stack.spacing = Constants.titleButtonSpacing
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

    @objc internal func didCancel() {
        onCancelHandler?()
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        // Wrapping only above the default text size keeps the default appearance unchanged.
        titleLabel.numberOfLines = traitCollection.preferredContentSizeCategory > Constants.largestSingleLineContentSize ? 0 : 1
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
            stackView.adyen.anchor(inside: safeAreaLayoutGuide)
            titleLabel.topAnchor.constraint(
                greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor,
                constant: Constants.titleVerticalPadding
            ).isActive = true
        }
        
        self.accessibilityIdentifier = "adyen.ModalToolbar"
        cancelButton.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "closeButton")

        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = style.backgroundColor
        cancelButton.tintColor = style.tintColor
        titleLabel.adjustsFontForContentSizeCategory = true
        guard let title = titleLabel.text, !title.isEmpty else { return }
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [
                NSAttributedString.Key.font: style.barTitle.font,
                NSAttributedString.Key.foregroundColor: style.barTitle.color,
                NSAttributedString.Key.backgroundColor: style.barTitle.backgroundColor
            ]
        )
    }

    private func setupLayoutForCenteredMode() {
        let centerConstraint = titleLabel.centerXAnchor.constraint(equalTo: safeAreaLayoutGuide.centerXAnchor)
        centerConstraint.priority = .defaultLow
        let cancelOnLeft = style.toolbarMode == .leftCancel
            || (style.toolbarMode == .natural && effectiveUserInterfaceLayoutDirection == .rightToLeft)
        let titleButtonSpacing = cancelOnLeft
            ? titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: cancelButton.rightAnchor, constant: Constants.titleButtonSpacing)
            : titleLabel.rightAnchor.constraint(lessThanOrEqualTo: cancelButton.leftAnchor, constant: -Constants.titleButtonSpacing)

        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            titleLabel.topAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.topAnchor, constant: Constants.titleVerticalPadding),
            titleLabel.leftAnchor.constraint(greaterThanOrEqualTo: safeAreaLayoutGuide.leftAnchor, constant: paddingWithMarginCorrection),
            titleLabel.rightAnchor.constraint(lessThanOrEqualTo: safeAreaLayoutGuide.rightAnchor, constant: -paddingWithMarginCorrection),
            centerConstraint,
            titleButtonSpacing,
            
            safeAreaLayoutGuide.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor),
            safeAreaLayoutGuide.heightAnchor.constraint(greaterThanOrEqualTo: cancelButton.heightAnchor),
            cancelPositionConstraint
        ])
    }

    private lazy var cancelPositionConstraint: NSLayoutConstraint = {
        let cancelPositionConstraint: NSLayoutConstraint

        switch style.toolbarMode {
        case .rightCancel:
            cancelPositionConstraint = safeAreaLayoutGuide.rightAnchor.constraint(
                equalTo: cancelButton.rightAnchor,
                constant: paddingWithMarginCorrection
            )
        case .leftCancel:
            cancelPositionConstraint = safeAreaLayoutGuide.leftAnchor.constraint(
                equalTo: cancelButton.leftAnchor,
                constant: -paddingWithMarginCorrection
            )
        case .natural:
            cancelPositionConstraint = safeAreaLayoutGuide.trailingAnchor.constraint(
                equalTo: cancelButton.trailingAnchor,
                constant: paddingWithMarginCorrection
            )
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
            if let defaultFont = button.titleLabel?.font {
                // Scaling the system default font keeps its size at the default text size.
                button.titleLabel?.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: defaultFont)
            }
            button.titleLabel?.adjustsFontForContentSizeCategory = true
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
