//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a switch item.
/// :nodoc:
public final class FormToggleItemView: FormValueItemView<Bool, FormToggleItemStyle, FormToggleItem> {

    // MARK: - UI elements

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
        switchControl.onTintColor = item.style.tintColor
        switchControl.isAccessibilityElement = false
        switchControl.setContentHuggingPriority(.required, for: .horizontal)
        switchControl.setContentCompressionResistancePriority(.required, for: .horizontal)
        switchControl.addTarget(self, action: #selector(switchControlValueChanged), for: .valueChanged)
        switchControl.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "switch") }

        return switchControl
    }()

    /// Initializes the switch item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: FormToggleItem) {
        super.init(item: item)

        showsSeparator = false

        isAccessibilityElement = true
        accessibilityLabel = item.title
        accessibilityTraits = switchControl.accessibilityTraits
        accessibilityValue = switchControl.accessibilityValue

        observe(item.publisher) { [weak self] value in
            self?.switchControl.isOn = value
        }

        addSubviews()
    }

    // MARK: - Private

    private func addSubviews() {
        addSubview(stackView)
        [titleLabel, switchControl].forEach(stackView.addArrangedSubview)

        setupLayout()
    }

    private func setupLayout() {
        stackView.adyen.anchor(inside: layoutMarginsGuide)
    }

    @objc private func switchControlValueChanged() {
        accessibilityValue = switchControl.accessibilityValue
        item.value = switchControl.isOn
    }

    // MARK: - Public

    /// :nodoc:
    @discardableResult
    override public func accessibilityActivate() -> Bool {
        switchControl.isOn = !switchControl.isOn
        switchControlValueChanged()

        return true
    }

    /// :nodoc:
    override public func reset() {
        item.value = false
    }
}
