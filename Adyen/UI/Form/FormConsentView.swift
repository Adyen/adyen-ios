//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenInternal
import UIKit

/// :nodoc:
public class FormConsentView: UIView {
    public init() {
        super.init(frame: .zero)
        
        addSubview(titleLabel)
        addSubview(consentSwitch)
        
        configureConstraints()
    }
    
    public required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public
    
    public var title: String? {
        didSet {
            guard let title = title else {
                return
            }
            
            let attributedTitle = NSAttributedString(string: title, attributes: Appearance.shared.textAttributes)
            titleLabel.attributedText = attributedTitle
            dynamicTypeController.observeDynamicType(for: titleLabel, withTextAttributes: Appearance.shared.textAttributes, textStyle: .body)
            accessibilityLabel = title
        }
    }
    
    public var isSelected: Bool {
        set {
            consentSwitch.isOn = isSelected
        }
        get {
            return consentSwitch.isOn
        }
    }
    
    public var onValueChanged: ((Bool) -> Void)?
    
    // MARK: - Private
    
    private let dynamicTypeController = DynamicTypeController()
    
    private func configureConstraints() {
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            
            consentSwitch.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 20.0),
            consentSwitch.trailingAnchor.constraint(equalTo: trailingAnchor),
            consentSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            
            bottomAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.numberOfLines = 0
        titleLabel.isAccessibilityElement = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return titleLabel
    }()
    
    private lazy var consentSwitch: UISwitch = {
        let consentSwitch = UISwitch(frame: .zero)
        consentSwitch.isOn = false
        consentSwitch.onTintColor = Appearance.shared.formAttributes.switchTintColor
        consentSwitch.thumbTintColor = Appearance.shared.formAttributes.switchThumbColor
        consentSwitch.tintColor = Appearance.shared.formAttributes.separatorColor
        consentSwitch.translatesAutoresizingMaskIntoConstraints = false
        consentSwitch.addTarget(self, action: #selector(consentSwitchValueChanged), for: .valueChanged)
        return consentSwitch
    }()
    
    @objc private func consentSwitchValueChanged() {
        onValueChanged?(consentSwitch.isOn)
    }
    
}
