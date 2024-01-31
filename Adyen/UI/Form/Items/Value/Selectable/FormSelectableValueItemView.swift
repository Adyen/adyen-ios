//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// An abstract view representing a selectable value item.
@_documentation(visibility: internal)
open class FormSelectableValueItemView<ValueType, ItemType: FormSelectableValueItem<ValueType?>>:
    FormValidatableValueItemView<ValueType?, ItemType> {
    
    internal var numberOfLines: Int = 1 {
        didSet {
            valueLabel.numberOfLines = numberOfLines
        }
    }
    
    override internal var accessibilityLabelView: UIView? { selectionButton }
    
    public required init(item: ItemType) {
        super.init(item: item)
        
        addSubview(selectionButton)
        
        configureConstraints()
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
        let stackView = UIStackView(arrangedSubviews: [contentStackView, alertLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8.0
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [labelStackView, chevronView])
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 8.0
        stackView.preservesSuperviewLayoutMargins = true
        
        return stackView
    }()
    
    private lazy var labelStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 8.0
        
        return stackView
    }()
    
    internal lazy var chevronView: UIImageView = {
        let chevron = UIImage(named: "chevron", in: Bundle.coreInternalResources, compatibleWith: nil)
        let imageView = UIImageView(image: chevron)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    /// The value label view.
    internal lazy var valueLabel: UILabel = {
        let valueLabel = ValueLabel(style: item.style.text)
        valueLabel.numberOfLines = numberOfLines
        valueLabel.isAccessibilityElement = false
        valueLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "valueLabel") }

        return valueLabel
    }()
    
    // MARK: - Selection
    
    @objc
    internal func selectionButtonTapped() {
        item.selectionHandler()
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
            valueLabel.text = item.placeholder
            valueLabel.textColor = item.style.placeholderText?.color ?? .Adyen.componentPlaceholderText
            resetValidationStatus()
            return
        }
        
        valueLabel.text = formattedValue
        valueLabel.textColor = item.style.text.color
        showValidation()
    }
    
    private func configureConstraints() {
        selectionButton.adyen.anchor(inside: self)
        separatorView.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4).isActive = true
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
