//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The interface of the delegate of a text item view.
/// :nodoc:
public protocol FormTextItemViewDelegate: FormValueItemViewDelegate {
    
    /// Invoked when the text entered in the item view's text field has reached the maximum length.
    ///
    /// - Parameter itemView: The item view in which the maximum length was reached.
    func didReachMaximumLength(in itemView: FormTextItemView)
    
    /// Invoked when the return key in the item view's text field is selected.
    ///
    /// - Parameter itemView: The item view in which the return key was selected.
    func didSelectReturnKey(in itemView: FormTextItemView)
    
}

/// A view representing a text item.
/// :nodoc:
open class FormTextItemView: FormValueItemView<FormTextItem>, UITextFieldDelegate {
    
    /// Initializes the text item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: FormTextItem) {
        super.init(item: item)
        
        addSubview(stackView)
        
        configureConstraints()
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var textDelegate: FormTextItemViewDelegate? {
        return delegate as? FormTextItemViewDelegate
    }
    
    // MARK: - Stack View
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 3.0
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
    }()
    
    // MARK: - Title Label
    
    private lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 13.0)
        titleLabel.textColor = defaultTitleLabelTextColor
        titleLabel.text = item.title
        
        return titleLabel
    }()
    
    private let defaultTitleLabelTextColor = UIColor.darkGray
    
    // MARK: - Text Field
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.font = .systemFont(ofSize: 17.0)
        textField.textColor = .black
        textField.placeholder = item.placeholder
        textField.autocorrectionType = item.autocorrectionType
        textField.autocapitalizationType = item.autocapitalizationType
        textField.keyboardType = item.keyboardType
        textField.returnKeyType = .next
        textField.delegate = self
        
        return textField
    }()
    
    // MARK: - Editing
    
    /// :nodoc:
    public override var isEditing: Bool {
        didSet {
            titleLabel.textColor = isEditing ? tintColor : defaultTitleLabelTextColor
        }
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        let constraints = [
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    open override var lastBaselineAnchor: NSLayoutYAxisAnchor {
        return textField.lastBaselineAnchor
    }
    
    // MARK: - Interaction
    
    /// :nodoc:
    open override var canBecomeFirstResponder: Bool {
        return textField.canBecomeFirstResponder
    }
    
    /// :nodoc:
    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        return textField.becomeFirstResponder()
    }
    
    /// :nodoc:
    @discardableResult
    open override func resignFirstResponder() -> Bool {
        return textField.resignFirstResponder()
    }
    
    /// :nodoc:
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        _ = becomeFirstResponder()
    }
    
    // MARK: - UITextFieldDelegate
    
    /// :nodoc:
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        isEditing = true
    }
    
    /// :nodoc:
    public func textFieldDidEndEditing(_ textField: UITextField) {
        isEditing = false
    }
    
    /// :nodoc:
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textDelegate?.didSelectReturnKey(in: self)
        
        return true
    }
    
    /// :nodoc:
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString: String) -> Bool {
        let text = textField.text ?? ""
        let newText = (text as NSString).replacingCharacters(in: range, with: replacementString) as String
        
        var sanitizedText = item.formatter?.sanitizedValue(for: newText) ?? newText
        let maximumLength = item.validator?.maximumLength(for: sanitizedText) ?? .max
        sanitizedText = sanitizedText.truncate(to: maximumLength)
        
        item.value = sanitizedText
        
        textDelegate?.didChangeValue(in: self)
        
        if sanitizedText.count == maximumLength {
            textDelegate?.didReachMaximumLength(in: self)
        }
        
        if let formatter = item.formatter {
            textField.text = formatter.formattedValue(for: newText)
            
            return false
        } else {
            return true
        }
    }
    
}
