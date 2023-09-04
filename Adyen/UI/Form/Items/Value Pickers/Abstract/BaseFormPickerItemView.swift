//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// :nodoc:
/// Represents a picker item view.
open class BaseFormPickerItemView<T: CustomStringConvertible & Equatable>: FormValueItemView<BasePickerElement<T>,
    FormTextItemStyle,
    BaseFormPickerItem<T>>,
    UIPickerViewDelegate,
    UIPickerViewDataSource {

    /// The underlying `UIPickerView`.
    internal lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return pickerView
    }()
    
    /// Toolbar above the picker view with buttons to dismiss it.
    internal lazy var pickerViewToolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: pickerView.frame.width, height: 44))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(handleDoneButtonTap))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton], animated: false)
        return toolbar
    }()

    /// Initializes the picker item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: BaseFormPickerItem<T>) {
        super.init(item: item)
        initialize()
        select(value: item.value)
        observe(item.$selectableValues) { [weak self] change in
            guard let self else { return }
            self.inputControl.showChevron = change.count > 1
            self.pickerView.reloadAllComponents()
            change.first.map(self.select)
        }
    }

    /// :nodoc:
    override open var canBecomeFirstResponder: Bool { true }

    /// :nodoc:
    @discardableResult
    override open func becomeFirstResponder() -> Bool {
        inputControl.becomeFirstResponder()
    }

    /// :nodoc:
    @discardableResult
    override open func resignFirstResponder() -> Bool {
        inputControl.resignFirstResponder()
    }

    // MARK: - Abstract

    internal func createInputControl() -> PickerTextInputControl {
        BasePickerInputControl(inputView: pickerView,
                               inputAccessoryView: pickerViewToolbar,
                               style: item.style.text)
    }

    internal func updateSelection() {
        inputControl.label = item.value.description
    }

    /// Function called right after `init` for additional initialization of controls.
    /// :nodoc:
    open func initialize() {
        addSubview(inputControl)
        inputControl.preservesSuperviewLayoutMargins = true
        (inputControl as UIView).adyen.anchor(inside: self)
    }

    /// The main control of the picker element that
    /// handles displaying the selected value and triggering the picker view.
    /// :nodoc:
    public lazy var inputControl: PickerTextInputControl = {
        let view = createInputControl()
        view.showChevron = item.selectableValues.count > 1
        view.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "inputControl") }
        view.onDidBecomeFirstResponder = { [weak self] in
            self?.isEditing = true
            self?.titleLabel.textColor = self?.tintColor
        }

        view.onDidResignFirstResponder = { [weak self] in
            self?.isEditing = false
            self?.titleLabel.textColor = self?.item.style.title.color
        }

        view.onDidTap = { [weak self] in
            guard let self, self.item.selectableValues.count > 1 else { return }
            self.becomeFirstResponder()
        }

        return view
    }()
    
    @objc private func handleDoneButtonTap() {
        resignFirstResponder()
    }

    // MARK: - UIPickerViewDelegate and UIPickerViewDataSource

    public func numberOfComponents(in pickerView: UIPickerView) -> Int { 1 }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        item.selectableValues.count
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < item.selectableValues.count else { return nil }
        return item.selectableValues[row].description
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < item.selectableValues.count else { return }
        select(value: item.selectableValues[row])
    }

    // MARK: - Internal

    internal func select(value: BasePickerElement<T>) {
        self.item.value = value
        updateSelection()

        let selectedIndex = item.selectableValues.firstIndex(where: { $0.identifier == item.value.identifier }) ?? 0
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
    }

}
