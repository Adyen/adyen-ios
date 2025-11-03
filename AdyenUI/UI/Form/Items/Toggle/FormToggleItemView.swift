//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view representing a switch item.
@_spi(AdyenInternal)
public final class FormToggleItemView: FormItemView<FormToggleItem> {

    // TODO: TO be passed as a dependency by FormViewController.ItemManager
    package let style: AdyenToggleStyle = .init()

    // MARK: - UI elements
    
    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = item.title
        label.numberOfLines = 0
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
        stackView.spacing = AdyenUIConstants.stackViewSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = AdyenUIConstants.contentInsets
        stackView.preservesSuperviewLayoutMargins = true
      
        return stackView
    }()

    internal lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        switchControl.isOn = item.value
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

        applyAdyenStyle(style)
        
        isAccessibilityElement = false
        accessibilityTraits = switchControl.accessibilityTraits
        accessibilityValue = switchControl.accessibilityValue
        
        setupObservation()
        addSubviews()
    }
    
    // MARK: - Public

    @discardableResult
    override public func accessibilityActivate() -> Bool {
        switchControl.isOn.toggle()
        switchControlValueChanged()
        return true
    }

    override public func reset() {
        item.value = false
    }
    
    // MARK: - AdyenTheme

    /// Applies all the style properties from AdyenToggleStyle to the FormToggleItemView.
    ///
    /// - Parameter style: The style to apply.
    private func applyAdyenStyle(_ style: AdyenToggleStyle) {
        stackView.backgroundColor = style.backgroundColor

        let titleStyle = style.title
        label.font = titleStyle.font
        label.textColor = titleStyle.color
        label.textAlignment = titleStyle.textAlignment

        switchControl.onTintColor = style.tintColor
        
        switch style.cornerRadius {
        case let .fixed(radius):
            stackView.layer.cornerRadius = radius
        default:
            break
        }
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
            self?.accessibilityLabel = value
        }
        
        observe(item.publisher) { [weak self] value in
            self?.switchControl.isOn = value
        }
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onVoiceOverStatusUpdate),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
    }

    @objc func switchControlValueChanged() {
        accessibilityValue = switchControl.accessibilityValue
        accessibilityTraits = switchControl.accessibilityTraits
        item.value = switchControl.isOn
    }
    
    @objc private func onVoiceOverStatusUpdate() {
        switchControl.isAccessibilityElement = !UIAccessibility.isVoiceOverRunning
        self.isAccessibilityElement = UIAccessibility.isVoiceOverRunning
    }
}
