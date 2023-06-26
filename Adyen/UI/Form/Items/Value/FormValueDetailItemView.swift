//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a value detail item.
@_spi(AdyenInternal)
open class FormValueDetailItemView<ValueType, ItemType: FormValueDetailItem<ValueType>>:
    FormValueItemView<ValueType, FormTextItemStyle, ItemType> {
    private var itemObserver: Observation?
    
    /// Initializes the value detail item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: ItemType) {
        super.init(item: item)
        
        addSubview(selectionButton)
        
        configureConstraints()
        setupObservers()
        
        updateValueLabel(with: item.formattedValue)
        updateValidationStatus()
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
        let valueLabel = UILabel(style: item.style.text)
        valueLabel.numberOfLines = 0
        valueLabel.isAccessibilityElement = false
        valueLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "valueLabel") }

        return valueLabel
    }()
    
    internal lazy var alertLabel: UILabel = {
        let alertLabel = UILabel(style: item.style.title)
        alertLabel.textColor = item.style.errorColor
        alertLabel.isAccessibilityElement = false
        alertLabel.numberOfLines = 0
        alertLabel.text = item.validationFailureMessage
        alertLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "alertLabel") }
        alertLabel.isHidden = true
        
        return alertLabel
    }()
    
    // MARK: - Selection
    
    @objc
    private func selectionButtonTapped() {
        item.selectionHandler?()
    }
    
    // MARK: - Convenience
    
    private func setupObservers() {
        itemObserver = observe(item.publisher) { [weak self] _ in
            self?.updateValidationStatus()
        }
        
        observe(item.$formattedValue) { [weak self] in
            self?.updateValueLabel(with: $0)
        }
        
        observe(item.$validationFailureMessage) { [weak self] in
            self?.alertLabel.text = $0
        }
    }
    
    private func updateValueLabel(with formattedValue: String?) {
        guard let formattedValue, !formattedValue.isEmpty else {
            valueLabel.text = item.placeholder
            valueLabel.textColor = item.style.placeholderText?.color ?? .Adyen.componentPlaceholderText
            return
        }
        
        valueLabel.text = formattedValue
        valueLabel.textColor = item.style.text.color
    }
    
    override open func configureSeparatorView() {
        let constraints = [
            separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private func configureConstraints() {
        selectionButton.adyen.anchor(inside: self)
        separatorView.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4).isActive = true
    }
    
    // MARK: - Validation
    
    override public func validate() {
        updateValidationStatus(forced: true)
    }
    
    private func updateValidationStatus(forced: Bool = false) {
        if !item.isValid(), forced {
            hideAlertLabel(false)
            highlightSeparatorView(color: item.style.errorColor)
            titleLabel.textColor = item.style.errorColor
            valueLabel.accessibilityLabel = item.validationFailureMessage
        } else {
            hideAlertLabel(true)
            unhighlightSeparatorView()
            titleLabel.textColor = defaultTitleColor
            valueLabel.accessibilityLabel = item.title
        }
    }
    
    private func hideAlertLabel(_ hidden: Bool, animated: Bool = true) {
        guard hidden || alertLabel.text != nil else { return }
        alertLabel.adyen.hide(animationKey: "hide_alertLabel", hidden: hidden, animated: animated)
    }
    
    internal func resetValidationStatus() {
        hideAlertLabel(true, animated: false)
        unhighlightSeparatorView()
        titleLabel.textColor = defaultTitleColor
        valueLabel.accessibilityLabel = item.title
    }
}
