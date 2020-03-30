//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A control to select a phone extension from a list.
internal class PhoneExtensionInputControl: UIControl, AnyFormItemView {
    
    /// :nodoc:
    internal weak var delegate: FormItemViewDelegate?
    
    /// :nodoc:
    internal var childItemViews: [AnyFormItemView] = []
    
    /// The country flag view.
    internal lazy var flagView: UILabel = UILabel()
    
    /// The chevron image view.
    internal lazy var chevronView: UIImageView = UIImageView(image: accessoryImage)
    
    /// The phone code label.
    internal lazy var phoneExtensionLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = style.backgroundColor
        label.textAlignment = style.textAlignment
        label.textColor = style.color
        label.font = style.font
        
        return label
    }()
    
    internal override var accessibilityIdentifier: String? {
        didSet {
            phoneExtensionLabel.accessibilityIdentifier = accessibilityIdentifier.map {
                ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "label")
            }
        }
    }
    
    /// The UI style.
    internal let style: TextStyle
    
    /// Executed when the view resigns as first responder.
    internal var onDidResignFirstResponder: (() -> Void)?
    
    /// Executed when the view becomes first responder.
    internal var onDidBecomeFirstResponder: (() -> Void)?
    
    /// Initializes a `PhoneExtensionInputControl`.
    ///
    /// - Parameter inputView: The input view used in place of the system keyboard.
    /// - Parameter style: The UI style.
    internal init(inputView: UIView, style: TextStyle) {
        _inputView = inputView
        self.style = style
        super.init(frame: CGRect.zero)
        addSubview(stackView)
        applyConstraints()
    }
    
    /// :nodoc:
    internal required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The input view.
    internal override var inputView: UIView? { return _inputView }
    
    /// :nodoc:
    internal override var canBecomeFirstResponder: Bool { return true }
    
    /// :nodoc:
    internal override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        onDidResignFirstResponder?()
        return result
    }
    
    /// :nodoc:
    internal override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        onDidBecomeFirstResponder?()
        return result
    }
    
    // MARK: - Private
    
    /// The stack view.
    private lazy var stackView: UIStackView = {
        chevronView.translatesAutoresizingMaskIntoConstraints = false
        flagView.translatesAutoresizingMaskIntoConstraints = false
        phoneExtensionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let stackView = UIStackView(arrangedSubviews: [flagView, chevronView, phoneExtensionLabel])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fillProportionally
        stackView.spacing = 6
        stackView.isUserInteractionEnabled = false
        
        return stackView
    }()
    
    /// The chevron image.
    private var accessoryImage: UIImage? { UIImage(named: "chevron_down",
                                                   in: Bundle.internalResources,
                                                   compatibleWith: nil) }
    
    /// :nodoc:
    private var _inputView: UIView
    
    /// :nodoc:
    private func applyConstraints() {
        stackView.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -6),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
}
