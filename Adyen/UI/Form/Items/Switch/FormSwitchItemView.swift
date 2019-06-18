//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a switch item.
/// :nodoc:
open class FormSwitchItemView: FormValueItemView<FormSwitchItem> {
    
    /// Initializes the switch item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: FormSwitchItem) {
        super.init(item: item)
        
        showsSeparator = false
        
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
        titleLabel.font = .systemFont(ofSize: 17.0)
        titleLabel.textColor = .black
        titleLabel.text = item.title
        titleLabel.numberOfLines = 0
        
        return titleLabel
    }()
    
    // MARK: - Switch Control
    
    private lazy var switchControl: UISwitch = {
        let switchControl = UISwitch()
        switchControl.isOn = item.value
        switchControl.addTarget(self, action: #selector(switchControlValueChanged), for: .valueChanged)
        switchControl.setContentHuggingPriority(.required, for: .horizontal)
        
        return switchControl
    }()
    
    @objc private func switchControlValueChanged() {
        item.value = switchControl.isOn
        
        switchDelegate?.didChangeValue(in: self)
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
