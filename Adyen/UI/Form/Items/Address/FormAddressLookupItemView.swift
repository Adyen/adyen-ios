//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

// TODO: Make more generic "FormDetailItemView"

internal class FormAddressLookupItemView<ItemType: FormAddressLookupItem>: FormValueItemView<PostalAddress?, FormTextItemStyle, ItemType> {
    
//    private let selectionButton = UIButton(type: .custom) // TODO: Check why the UIControl doesn't work as expected
    private var addressObserver: Observation?
    
    internal required init(item: ItemType) {
        super.init(item: item)
        
        addSubview(itemStackView)
        
        configureConstraints()
        setupObservers()
        updateValueLabel()
        updateValidationStatus()
    }
    
    // MARK: - Views
    
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
        let imageView = UIImageView(
            image: .init(
                named: "chevron",
                in: Bundle.coreInternalResources,
                compatibleWith: nil
            )
        )
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// The value label view.
    public lazy var valueLabel: UILabel = {
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
    
    // TODO: Switch to a UIControl / UIButton instead as becoming first responser is also triggered when another form field finishes
    
    override internal var canBecomeFirstResponder: Bool { item.selectionHandler != nil }
    
    override internal func becomeFirstResponder() -> Bool {
        guard let selectionHandler = item.selectionHandler else { return false }
        
        selectionHandler()
        return true
    }
    
    // MARK: - Convenience
    
    private func setupObservers() {
        addressObserver = observe(item.publisher) { [weak self] _ in
            self?.updateValueLabel()
            self?.updateValidationStatus()
        }
        
        observe(item.$validationFailureMessage) { [weak self] newValue in
            self?.alertLabel.text = newValue
        }
    }
    
    private func updateValueLabel() {
        guard let address = item.value, !address.formatted.isEmpty else {
            // TODO: Use a different placeholder text so it can be customized by the merchant!
            valueLabel.text = localizedString(.billingAddressSectionTitle, item.localizationParameters)
            valueLabel.textColor = item.style.placeholderText?.color ?? .Adyen.componentPlaceholderText
            return
        }
        
        valueLabel.text = address.formatted
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
        itemStackView.adyen.anchor(inside: self)
        separatorView.bottomAnchor.constraint(equalTo: valueLabel.bottomAnchor, constant: 4).isActive = true
    }
    
    // MARK: - Validation
    
    override public func validate() {
        updateValidationStatus(forced: true)
    }
    
    private func updateValidationStatus(forced: Bool = false) {
        if !item.isValid() && forced {
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
}