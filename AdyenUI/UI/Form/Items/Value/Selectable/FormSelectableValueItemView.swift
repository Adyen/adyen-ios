//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

package class FormSelectableValueItemView<ValueType, ItemType: FormSelectableValueItem<ValueType?>>:
    FormValidatableValueItemView<ValueType?, ItemType> {

    internal var numberOfLines: Int = 1 {
        didSet {
            valueLabel.numberOfLines = numberOfLines
        }
    }

    override internal var accessibilityLabelView: UIView? { selectionButton }

    package required init(item: ItemType, theme: AdyenTheme) {
        super.init(item: item, theme: theme)

        addSubview(selectionButton)

        configureConstraints()
        apply(theme)
        
        setupObservers()

        updateValueLabel(with: item.formattedValue)
    }

    // MARK: - Views

    private lazy var selectionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.addTarget(self, action: #selector(selectionButtonTapped), for: .touchUpInside)
        button.preservesSuperviewLayoutMargins = true
        button.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(itemStackView)
        itemStackView.isUserInteractionEnabled = false
        itemStackView.adyen.anchor(inside: button)

        return button
    }()

    private lazy var itemStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, containerView, footerLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = AdyenUIConstants.stackViewSpacing
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    internal lazy var containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentStackView)
        contentStackView.adyen.anchor(inside: view, with: AdyenUIConstants.contentInsets)

        // Ensure minimum height for empty state
        view.heightAnchor.constraint(
            greaterThanOrEqualToConstant: AdyenUIConstants.minimumInputHeight
        ).isActive = true

        return view
    }()

    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [valueLabel, chevronView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = AdyenUIConstants.stackViewSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false

        return stackView
    }()

    internal lazy var chevronView: UIImageView = {
        let chevron = UIImage(
            named: "chevron",
            in: Bundle.coreInternalResources,
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)

        let imageView = UIImageView(image: chevron)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()

    internal lazy var valueLabel: UILabel = {
        let valueLabel = ValueLabel()
        valueLabel.numberOfLines = numberOfLines
        valueLabel.isAccessibilityElement = false
        valueLabel.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "valueLabel")
        }

        return valueLabel
    }()

    // MARK: - Selection

    @objc
    internal func selectionButtonTapped() {
        item.selectionHandler()
    }

    // MARK: - Styling

    private func apply(_ theme: AdyenTheme) {
        let style = theme.elements.textField

        containerView.backgroundColor = style.containerColor
        containerView.layer.borderWidth = style.borderWidth
        containerView.layer.borderColor = style.borderColor.cgColor

        switch style.cornerRadius {
        case let .fixed(radius):
            containerView.layer.cornerRadius = radius
        default:
            containerView.layer.cornerRadius = AdyenUIConstants.defaultCornerRadius
        }

        chevronView.tintColor = theme.colors.primary
        valueLabel.apply(theme.elements.labels.body)
    }

    private func updateContainerBorderColor(isValid: Bool) {
        let style = theme.elements.textField
        let borderColor = isValid ? style.borderColor : style.errorColor
        containerView.layer.borderColor = borderColor.cgColor
    }

    // MARK: - Convenience

    private func setupObservers() {
        observe(item.$formattedValue) { [weak self] in
            self?.updateValueLabel(with: $0)
        }
    }

    private func updateValueLabel(with formattedValue: String?) {
        accessibilityLabelView?.accessibilityValue = formattedValue

        guard let formattedValue, !formattedValue.isEmpty else {
            valueLabel.text = nil
            resetValidationStatus()
            return
        }

        valueLabel.text = formattedValue
        valueLabel.textColor = theme.elements.labels.body.color
        showValidation()
    }

    private func configureConstraints() {
        selectionButton.adyen.anchor(inside: self)
    }

    // MARK: - Validation

    override open func updateValidationStatus(forced: Bool = false) {
        guard forced else {
            showHint()
            updateContainerBorderColor(isValid: true)
            accessibilityLabelView?.accessibilityLabel = item.title
            return
        }

        if item.isValid() {
            showHint()
            updateContainerBorderColor(isValid: true)
            accessibilityLabelView?.accessibilityLabel = item.title
        } else {
            showError(item.validationFailureMessage)
            updateContainerBorderColor(isValid: false)
            accessibilityLabelView?.accessibilityLabel = [
                item.title,
                item.validationFailureMessage
            ].compactMap { $0 }.joined(separator: ", ")

            if let validationStatus = item.validationStatus(),
               let error = validationStatus.validationError {
                item.onDidShowValidationError?(error)
            }
        }
    }

    override internal func resetValidationStatus() {
        showHint()
        updateContainerBorderColor(isValid: true)
        accessibilityLabelView?.accessibilityLabel = item.title
    }
}

/// A label reporting it's intrinsic content size to match the text field of the ``FormTextItemView``
private class ValueLabel: UILabel {

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return .init(
            width: size.width,
            height: size.height + 3
        )
    }
}
