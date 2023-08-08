//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// An abstract view representing a validatable value item.
@_spi(AdyenInternal)
open class FormValidatableValueItemView<ValueType, ItemType: FormValidatableValueItem<ValueType>>:
    FormValueItemView<ValueType, FormTextItemStyle, ItemType>, AnyFormValidatableItemView {
    
    private var itemObserver: Observation?
    
    /// The view to set the `accessibilityLabel` on when invalid
    internal var accessibilityLabelView: UIView? {
        AdyenAssertion.assertionFailure(message: "'\(#function)' needs to be implemented on '\(String(describing: Self.self))'")
        return nil
    }
    
    public required init(item: ItemType) {
        super.init(item: item)
        
        setupObservers()
        updateValidationStatus()
    }
    
    // MARK: - Views
    
    /// The alert label to be used to indicate an issue with the value
    ///
    /// The intended use is to put it inside of a UIStackView as it will be hidden based on the validity of the item
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
    
    // MARK: - Convenience
    
    private func setupObservers() {
        itemObserver = observe(item.publisher) { [weak self] _ in
            self?.updateValidationStatus()
        }
        
        observe(item.$validationFailureMessage) { [weak self] in
            self?.alertLabel.text = $0
        }
    }
    
    override open func configureSeparatorView() {
        let constraints = [
            separatorView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1.0)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Validation
    
    public var isValid: Bool {
        item.isValid()
    }
    
    override public func validate() {
        updateValidationStatus(forced: true)
    }
    
    open func updateValidationStatus(forced: Bool = false) {
        
        guard forced else {
            hideAlertLabel(true)
            isEditing ? highlightSeparatorView(color: tintColor) : unhighlightSeparatorView()
            titleLabel.textColor = defaultTitleColor
            accessibilityLabelView?.accessibilityLabel = item.title
            return
        }
        
        if item.isValid() {
            hideAlertLabel(true)
            highlightSeparatorView(color: tintColor)
            titleLabel.textColor = tintColor
            accessibilityLabelView?.accessibilityLabel = item.title
        } else {
            hideAlertLabel(false)
            highlightSeparatorView(color: item.style.errorColor)
            titleLabel.textColor = item.style.errorColor
            accessibilityLabelView?.accessibilityLabel = [
                item.title,
                item.validationFailureMessage
            ].compactMap { $0 }.joined(separator: ", ")
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
        accessibilityLabelView?.accessibilityLabel = item.title
    }
}

@_spi(AdyenInternal)
public protocol AnyFormValidatableItemView {
    
    /// Whether or not the value is valid
    var isValid: Bool { get }
}
