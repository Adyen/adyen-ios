//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Represents a picker item view.
internal final class FormPhoneExtensionPickerItemView: FormValueItemView<FormPhoneExtensionPickerItem> {
    
    /// The underlying `UIPickerView`.
    internal lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return pickerView
    }()
    
    /// Initializes the picker item view.
    ///
    /// - Parameter item: The item represented by the view.
    internal required init(item: FormPhoneExtensionPickerItem) {
        super.init(item: item)
        initialize()
    }
    
    /// :nodoc:
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// :nodoc:
    internal override var canBecomeFirstResponder: Bool { true }
    
    /// :nodoc:
    internal override func becomeFirstResponder() -> Bool {
        return inputControl.becomeFirstResponder()
    }
    
    /// :nodoc:
    internal override func resignFirstResponder() -> Bool {
        return inputControl.resignFirstResponder()
    }
    
    // MARK: - Layout
    
    private func configureConstraints() {
        inputControl.translatesAutoresizingMaskIntoConstraints = false
        let constraints = [
            inputControl.topAnchor.constraint(equalTo: topAnchor),
            inputControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            inputControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            inputControl.bottomAnchor.constraint(equalTo: bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    // MARK: - Private
    
    private func initialize() {
        showsSeparator = false
        addSubview(inputControl)
        backgroundColor = item.style.backgroundColor
        configureConstraints()
        updateSelection()
    }
    
    private func updateSelection() {
        inputControl.phoneExtensionLabel.text = item.value.phoneExtension
        inputControl.flagView.text = item.value.identifier.countryFlag
        
        let selectedIndex = item.selectableValues.firstIndex(where: { $0.identifier == item.value.identifier }) ?? 0
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
        
        if let delegate = delegate as? FormValueItemViewDelegate {
            delegate.didChangeValue(in: self)
        }
    }
    
    private lazy var inputControl: PhoneExtensionInputControl = {
        let view = PhoneExtensionInputControl(inputView: pickerView, style: item.style.text)
        view.addTarget(self, action: #selector(self.handleTapAction), for: .touchUpInside)
        view.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "inputControl") }
        view.onDidBecomeFirstResponder = { [weak self] in
            self?.isEditing = true
        }
        
        view.onDidResignFirstResponder = { [weak self] in
            self?.isEditing = false
        }
        
        return view
    }()
    
    @objc private func handleTapAction() {
        _ = becomeFirstResponder()
    }
    
}

/// :nodoc:
extension FormPhoneExtensionPickerItemView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    /// :nodoc:
    internal func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }
    
    /// :nodoc:
    internal func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        item.selectableValues.count
    }
    
    /// :nodoc:
    internal func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < item.selectableValues.count else { return nil }
        return item.selectableValues[row].title
    }
    
    /// :nodoc:
    internal func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < item.selectableValues.count else { return }
        item.value = item.selectableValues[row]
        updateSelection()
    }
    
}
