//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a switch item.
/// :nodoc:
public final class FormSwitchItemView: FormValueItemView<FormSwitchItem> {
    
    /// Initializes the switch item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: FormSwitchItem) {
        super.init(item: item)
        
        showsSeparator = false
        
        isAccessibilityElement = true
        accessibilityLabel = item.title
        accessibilityTraits = switchControl.accessibilityTraits
        accessibilityValue = switchControl.accessibilityValue
        
        backgroundColor = item.style.backgroundColor
        
        addSubview(stackView)
        
        configureConstraints()
    }
    
    private var switchDelegate: FormValueItemViewDelegate? {
        return delegate as? FormValueItemViewDelegate
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = item.style.title.font
        titleLabel.textColor = item.style.title.color
        titleLabel.textAlignment = item.style.title.textAlignment
        titleLabel.backgroundColor = item.style.title.backgroundColor
        titleLabel.text = item.title
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }
        
        return titleLabel
    }()
    
    // MARK: - Switch Control
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = item.value
        switchControl.isAccessibilityElement = false
        switchControl.addTarget(self, action: #selector(switchControlValueChanged), for: .valueChanged)
        switchControl.setContentHuggingPriority(.required, for: .horizontal)
        
        return switchControl
    }()
    
    @objc private func switchControlValueChanged() {
        accessibilityValue = switchControl.accessibilityValue
        item.value = switchControl.isOn
        
        switchDelegate?.didChangeValue(in: self)
    }
    
    /// :nodoc:
    public override func accessibilityActivate() -> Bool {
        switchControl.isOn = !switchControl.isOn
        switchControlValueChanged()
        
        return true
    }
    
    // MARK: - Stack View
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, switchControl])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8.0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
