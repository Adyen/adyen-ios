//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a switch item.
@_spi(AdyenInternal)
public final class FormToggleItemView: FormItemView<FormToggleItem> {

    // MARK: - UI elements
    
    private lazy var label: UILabel = {
        let label = UILabel(style: item.style.title)
        label.text = item.title
        label.numberOfLines = 0
        label.isAccessibilityElement = false
        label.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel")
        }
        return label
    }()

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8.0
        return stackView
    }()

    internal lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.isOn = item.value
        switchControl.accessibilityLabel = item.title
        switchControl.onTintColor = item.style.tintColor
        switchControl.isAccessibilityElement = true
        switchControl.setContentHuggingPriority(.required, for: .horizontal)
        switchControl.setContentCompressionResistancePriority(.required, for: .horizontal)
        switchControl.addTarget(self, action: #selector(switchControlValueChanged), for: .valueChanged)
        switchControl.accessibilityIdentifier = item.identifier.map {
            ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "switch")
        }
        return switchControl
    }()

    /// Initializes the switch item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: FormToggleItem) {
        super.init(item: item)
        
        backgroundColor = item.style.backgroundColor

        isAccessibilityElement = false
        
        setupObservation()
        addSubviews()
    }
    
    // MARK: - Public

    override public func reset() {
        item.value = false
    }
}

// MARK: - Private

private extension FormToggleItemView {
    
    func addSubviews() {
        addSubview(stackView)
        [label, switchControl].forEach(stackView.addArrangedSubview)
        stackView.adyen.anchor(inside: layoutMarginsGuide)
    }
    
    func setupObservation() {
        observe(item.$title) { [weak self] value in
            self?.label.text = value
            self?.switchControl.accessibilityLabel = value
        }
        
        observe(item.publisher) { [weak self] value in
            self?.switchControl.isOn = value
        }
    }

    @objc func switchControlValueChanged() {
        item.value = switchControl.isOn
    }
}
