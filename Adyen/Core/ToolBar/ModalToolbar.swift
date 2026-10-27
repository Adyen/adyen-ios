//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_spi(AdyenInternal)
public class ModalToolbar: UIView, AnyNavigationBar {
    private enum Constants {
        static let minimumCancelButtonSize: CGFloat = 44
        static let titleButtonSpacing: CGFloat = 16
        static let titleVerticalPadding: CGFloat = 16
        static let minimumTitleWidth: CGFloat = 1
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
        label.numberOfLines = 0
        label.accessibilityTraits.insert(.header)
        return label
    }()

    internal lazy var cancelButton: UIButton = {
        let button = createCancelButton()
        button.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(didCancel), for: .touchUpInside)
        button.accessibilityLabel = Bundle(for: UIApplication.self).localizedString(forKey: "Cancel", value: nil, table: nil)
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumCancelButtonSize).isActive = true
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: Constants.minimumCancelButtonSize).isActive = true
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

    override public var intrinsicContentSize: CGSize {
        let buttonWidth = max(Constants.minimumCancelButtonSize, cancelButton.intrinsicContentSize.width)
        let buttonSpace = buttonWidth + Constants.titleButtonSpacing
        let titleInset = 2 * paddingWithMarginCorrection + buttonSpace
        let width = bounds.width > 0 ? bounds.width : Dimensions.expectedWidth(for: window)
        let titleSize = titleLabel.sizeThatFits(CGSize(
            width: max(Constants.minimumTitleWidth, width - safeAreaInsets.left - safeAreaInsets.right - titleInset),
            height: .greatestFiniteMagnitude
        ))
        return CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(titleSize.height + 2 * Constants.titleVerticalPadding, cancelButton.intrinsicContentSize.height)
        )
    }

    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory else { return }
        invalidateIntrinsicContentSize()
        adyen.updatePreferredContentSize()
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
        }
        
        self.accessibilityIdentifier = "adyen.ModalToolbar"
        cancelButton.accessibilityIdentifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "closeButton")

        setupStyle()
    }

    private func setupStyle() {
        backgroundColor = style.backgroundColor
        cancelButton.tintColor = style.tintColor
        titleLabel.adyen.apply(style.barTitle)
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
            safeAreaLayoutGuide.topAnchor.constraint(equalTo: titleLabel.topAnchor),
            safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor),
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
            let button = FocusableCancelButton(type: .system)
            let cancelText = Bundle(for: UIApplication.self).localizedString(forKey: "Cancel", value: nil, table: nil)
            button.setTitle(cancelText, for: .normal)
            button.titleLabel?.font = .preferredFont(forTextStyle: .body)
            button.titleLabel?.adjustsFontForContentSizeCategory = true
            button.setTitleColor(style.tintColor, for: .normal)
            return button
        }

        switch style.cancelButton {
        case .legacy:
            return legacy()
        case let .custom(image):
            button = FocusableCancelButton(type: .custom)
            button.setImage(image, for: .normal)
        default:
            if #available(iOS 13.0, *) {
                button = FocusableCancelButton(type: .close)
                button.widthAnchor.constraint(equalTo: button.heightAnchor).isActive = true
            } else {
                return legacy()
            }
        }

        return button
    }
}

private final class FocusableCancelButton: UIButton {
    override var canBecomeFocused: Bool {
        isEnabled && isUserInteractionEnabled && !isHidden && alpha > 0
    }
}
