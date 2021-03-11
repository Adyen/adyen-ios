//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds different types of `FormItemView's`  from the corresponding concrete `FormItem`.
/// :nodoc:
public struct FormItemViewBuilder {
    
    /// Builds `FormSwitchItemView` from `FormSwitchItem`.
    /// :nodoc:
    public func build(with item: FormSwitchItem) -> FormItemView<FormSwitchItem> {
        FormSwitchItemView(item: item)
    }
    
    /// Builds `FormSplitItemView` from `FormSplitItem`.
    /// :nodoc:
    public func build(with item: FormSplitItem) -> FormItemView<FormSplitItem> {
        FormSplitItemView(item: item)
    }
    
    /// Builds `PhoneNumberItemView` from `PhoneNumberItem`.
    /// :nodoc:
    public func build(with item: FormPhoneNumberItem) -> FormItemView<FormPhoneNumberItem> {
        FormPhoneNumberItemView(item: item)
    }
    
    /// Builds `FormPhoneExtensionPickerItemView` from `FormPhoneExtensionPickerItem`.
    /// :nodoc:
    internal func build(with item: FormPhoneExtensionPickerItem) -> FormItemView<FormPhoneExtensionPickerItem> {
        FormPhoneExtensionPickerItemView(item: item)
    }
    
    /// Builds `FormTextInputItemView` from `FormTextInputItem`.
    /// :nodoc:
    public func build(with item: FormTextInputItem) -> FormItemView<FormTextInputItem> {
        FormTextInputItemView(item: item)
    }
    
    /// Builds `ListItemView` from `ListItem`.
    /// :nodoc:
    public func build(with item: ListItem) -> ListItemView {
        let listView = ListItemView()
        listView.item = item
        return listView
    }
    
    /// Builds `FormButtonItemView` from `FormButtonItem`.
    /// :nodoc:
    public func build(with item: FormButtonItem) -> FormItemView<FormButtonItem> {
        FormButtonItemView(item: item)
    }
    
    /// Builds `FormSeparatorItemView` from `FormSeparatorItem`.
    /// :nodoc:
    public func build(with item: FormSeparatorItem) -> FormItemView<FormSeparatorItem> {
        FormSeparatorItemView(item: item)
    }
}
