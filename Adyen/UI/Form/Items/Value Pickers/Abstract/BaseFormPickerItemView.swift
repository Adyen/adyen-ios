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

    /// Initializes the picker item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: BaseFormPickerItem<T>) {
        super.init(item: item)
        initialize()
        select(value: item.value)
    }

    /// :nodoc:
    override open var canBecomeFirstResponder: Bool { true }

    /// :nodoc:
    override open func becomeFirstResponder() -> Bool {
        inputControl.becomeFirstResponder()
    }

    /// :nodoc:
    override open func resignFirstResponder() -> Bool {
        inputControl.resignFirstResponder()
    }

    // MARK: - Abstract

    internal func getInputControl() -> PickerTextInputControl {
        BasePickerInputControl(inputView: pickerView, style: item.style.text)
    }

    internal func updateSelection() {
        inputControl.label = item.value.description
    }

    internal func initialize() {
        addSubview(inputControl)
        inputControl.translatesAutoresizingMaskIntoConstraints = false
        inputControl.preservesSuperviewLayoutMargins = true
        (inputControl as UIView).adyen.anchor(inside: self)
    }

    internal lazy var inputControl: PickerTextInputControl = {
        let view = getInputControl()
        view.showChevron = item.selectableValues.count > 1
        view.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "inputControl") }
        view.onDidBecomeFirstResponder = { [weak self] in
            self?.isEditing = true
        }

        view.onDidResignFirstResponder = { [weak self] in
            self?.isEditing = false
        }

        view.onDidTap = { [weak self] in
            guard let self = self, self.item.selectableValues.count > 1 else { return }
            _ = self.becomeFirstResponder()
        }

        return view
    }()

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

    // MARK: - Private

    private func select(value: BasePickerElement<T>) {
        self.item.value = value
        updateSelection()

        let selectedIndex = item.selectableValues.firstIndex(where: { $0.identifier == item.value.identifier }) ?? 0
        pickerView.selectRow(selectedIndex, inComponent: 0, animated: false)
    }

}
