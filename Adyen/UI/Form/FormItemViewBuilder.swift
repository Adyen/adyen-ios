//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds different types of `FormItemView's`  from the corresponding concrete `FormItem`.
/// :nodoc:
public struct FormItemViewBuilder {
    
    /// Builds `FormHeaderItemView` from `FormHeaderItem`.
    /// :nodoc:
    public func build(with item: FormHeaderItem) -> FormItemView<FormHeaderItem> {
        return FormHeaderItemView(item: item)
    }
    
    /// Builds `FormFooterItemView` from `FormFooterItem`.
    /// :nodoc:
    public func build(with item: FormFooterItem) -> FormItemView<FormFooterItem> {
        return FormFooterItemView(item: item)
    }
    
    /// Builds `FormSwitchItemView` from `FormSwitchItem`.
    /// :nodoc:
    public func build(with item: FormSwitchItem) -> FormItemView<FormSwitchItem> {
        return FormSwitchItemView(item: item)
    }
    
    /// Builds `FormSplitTextItemView` from `FormSplitTextItem`.
    /// :nodoc:
    public func build(with item: FormSplitTextItem) -> FormItemView<FormSplitTextItem> {
        return FormSplitTextItemView(item: item)
    }
    
    /// Builds `PhoneNumberItemView` from `PhoneNumberItem`.
    /// :nodoc:
    public func build(with item: FormPhoneNumberItem) -> FormItemView<FormPhoneNumberItem> {
        return FormPhoneNumberItemView(item: item)
    }
    
    /// Builds `FormPhoneExtensionPickerItemView` from `FormPhoneExtensionPickerItem`.
    /// :nodoc:
    internal func build(with item: FormPhoneExtensionPickerItem) -> FormItemView<FormPhoneExtensionPickerItem> {
        return FormPhoneExtensionPickerItemView(item: item)
    }
    
    /// Builds `FormTextInputItemView` from `FormTextInputItem`.
    /// :nodoc:
    public func build(with item: FormTextInputItem) -> FormItemView<FormTextInputItem> {
        return FormTextInputItemView(item: item)
    }
}
