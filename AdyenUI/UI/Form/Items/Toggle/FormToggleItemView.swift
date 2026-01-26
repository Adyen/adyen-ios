//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// A view representing a switch item.
@_spi(AdyenInternal)
public final class FormToggleItemView: FormItemView<FormToggleItem> {

    package let theme: AdyenTheme

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

    /// Initializes the switch item view with a theme.
    public init(item: FormToggleItem, theme: AdyenTheme) {
        self.theme = theme
        super.init(item: item)

        configure()

        isAccessibilityElement = false
        accessibilityTraits = switchControl.accessibilityTraits
        accessibilityValue = switchControl.accessibilityValue

        setupObservation()
        addSubviews()
    }

    /// Initializes the switch item view with default theme.
    public required convenience init(item: FormToggleItem) {
        self.init(item: item, theme: .default)
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

    // MARK: - Private

    /// Configures all styling from theme.
    private func configure() {
        let style = theme.elements.switch

        stackView.backgroundColor = style.backgroundColor

        label.apply(style.title)

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
