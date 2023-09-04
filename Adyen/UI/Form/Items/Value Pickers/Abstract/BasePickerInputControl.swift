//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Interface for a basic picker input control.
/// :nodoc:
public protocol PickerTextInputControl: UIView {

    /// Executed when the view resigns as first responder.
    var onDidResignFirstResponder: (() -> Void)? { get set }

    /// Executed when the view becomes first responder.
    var onDidBecomeFirstResponder: (() -> Void)? { get set }

    /// Executed when the view detected tap.
    var onDidTap: (() -> Void)? { get set }

    /// Controls visibility of chevron view.
    var showChevron: Bool { get set }

    /// Selection value label text
    var label: String? { get set }
    
}

/// :nodoc:
/// A control to select a value from a list.
class BasePickerInputControl: UIControl, PickerTextInputControl {

    let style: TextStyle

    var childItemViews: [AnyFormItemView] = []

    lazy var chevronView = UIImageView(image: accessoryImage)

    var onDidResignFirstResponder: (() -> Void)?

    var onDidBecomeFirstResponder: (() -> Void)?

    var onDidTap: (() -> Void)?

    override var inputView: UIView? { customInputView }
    
    override var inputAccessoryView: UIView? { customInputAccessoryView }

    override var canBecomeFirstResponder: Bool { true }

    var accessoryImage: UIImage? { UIImage(named: "chevron_down",
                                           in: Bundle.coreInternalResources,
                                           compatibleWith: nil) }

    var customInputView: UIView
    
    var customInputAccessoryView: UIView

    var showChevron: Bool {
        get { !chevronView.isHidden }
        set { chevronView.isHidden = !newValue }
    }

    var label: String? {
        get { valueLabel.text }
        set { valueLabel.text = newValue }
    }

    /// The phone code label.
    lazy var valueLabel = UILabel(style: style)

    override var accessibilityIdentifier: String? {
        didSet {
            valueLabel.accessibilityIdentifier = accessibilityIdentifier.map {
                ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "label")
            }
        }
    }

    // MARK: PickerTextInputControl protocol

    /// Initializes a `PhoneExtensionInputControl`.
    ///
    /// - Parameter inputView: The input view used in place of the system keyboard.
    /// - Parameter inputAccessoryView: The accessory view to show above the input view.
    /// - Parameter style: The UI style.
    init(inputView: UIView, inputAccessoryView: UIView, style: TextStyle) {
        self.customInputView = inputView
        self.customInputAccessoryView = inputAccessoryView
        self.style = style
        super.init(frame: CGRect.zero)

        setupView()
        addTarget(self, action: #selector(self.handleTapAction), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// :nodoc:
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        onDidResignFirstResponder?()
        return result
    }

    /// :nodoc:
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        onDidBecomeFirstResponder?()
        return result
    }

    // MARK: - Private

    /// The stack view.
    open func setupView() {
        chevronView.setContentHuggingPriority(.defaultHigh, for: .horizontal)

        let stackView = UIStackView(arrangedSubviews: [valueLabel, chevronView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 6
        stackView.isUserInteractionEnabled = false

        addSubview(stackView)
        stackView.adyen.anchor(inside: self, with: .init(top: 0, left: 0, bottom: -1, right: -6))
    }

    @objc
    private func handleTapAction() {
        onDidTap?()
    }

}
