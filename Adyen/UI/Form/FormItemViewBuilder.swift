//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds different types of `FormItemView's`  from the corresponding concrete `FormItem`.
@_spi(AdyenInternal)
public struct FormItemViewBuilder {
    
    /// Builds `FormToggleItemView` from `FormToggleItem`.
    package func build(with item: FormToggleItem) -> FormItemView<FormToggleItem> {
        FormToggleItemView(item: item)
    }
    
    /// Builds `FormSplitItemView` from `FormSplitItem`.
    package func build(with item: FormSplitItem) -> FormItemView<FormSplitItem> {
        FormSplitItemView(item: item)
    }
    
    /// Builds `PhoneNumberItemView` from `PhoneNumberItem`.
    package func build(with item: FormPhoneNumberItem) -> FormItemView<FormPhoneNumberItem> {
        FormPhoneNumberItemView(item: item)
    }
    
    /// Builds `FormPhoneExtensionPickerItemView` from `FormPhoneExtensionPickerItem`.
    package func build(with item: FormPhoneExtensionPickerItem) -> BaseFormPickerItemView<PhoneExtension> {
        FormPhoneExtensionPickerItemView(item: item)
    }

    /// Builds `FormIssuerPickerItemView` from `FormIssuerPickerItem`.
    package func build(with item: FormIssuersPickerItem) -> BaseFormPickerItemView<Issuer> {
        FormIssuersPickerItemView(item: item)
    }

    /// Builds `FormTextInputItemView` from `FormTextInputItem`.
    package func build(with item: FormTextInputItem) -> FormItemView<FormTextInputItem> {
        FormTextInputItemView(item: item)
    }
    
    /// Builds `ListItemView` from `ListItem`.
    package func build(with item: ListItem) -> ListItemView {
        let listView = ListItemView()
        listView.item = item
        return listView
    }
    
    /// Builds `FormButtonItemView` from `FormButtonItem`.
    package func build(with item: FormButtonItem) -> FormItemView<FormButtonItem> {
        FormButtonItemView(item: item)
    }
    
    /// Builds `FormImageView` from `FormImageItem`.
    package func build(with item: FormImageItem) -> FormItemView<FormImageItem> {
        FormImageView(item: item)
    }

    /// Builds `FormSeparatorItemView` from `FormSeparatorItem`.
    package func build(with item: FormSeparatorItem) -> FormItemView<FormSeparatorItem> {
        FormSeparatorItemView(item: item)
    }

    /// Builds `FormErrorItemView` from `FormErrorItem`.
    package func build(with item: FormErrorItem) -> FormItemView<FormErrorItem> {
        FormErrorItemView(item: item)
    }
    
    /// Builds `FormVerticalStackItemView` from `FormAddressItem`.
    package func build(with item: FormAddressItem) -> FormItemView<FormAddressItem> {
        FormVerticalStackItemView(item: item)
    }

    /// Builds `FormSpacerItemView` from `FormSpacerItem`.
    package func build(with item: FormSpacerItem) -> FormItemView<FormSpacerItem> {
        FormSpacerItemView(item: item)
    }
    
    /// Builds `FormTextItemView` from `FormPostalCodeItem`.
    package func build(with item: FormPostalCodeItem) -> FormItemView<FormPostalCodeItem> {
        FormTextItemView(item: item)
    }
    
    /// Builds `FormSearchButtonItemView` from `FormSearchButtonItem`.
    package func build(with item: FormSearchButtonItem) -> FormItemView<FormSearchButtonItem> {
        FormSearchButtonItemView(item: item)
    }
    
    /// Builds `FormAddressPickerItemView` from `FormAddressPickerItem`.
    package func build(with item: FormAddressPickerItem) -> FormItemView<FormAddressPickerItem> {
        FormAddressPickerItemView(item: item)
    }
    
    /// Builds `FormPickerItemView` from `FormPickerItem`.
    package func build(with item: FormPickerItem) -> FormItemView<FormPickerItem> {
        FormPickerItemView(item: item)
    }

    package static func build(_ item: FormItem) -> AnyFormItemView {
        let itemView = item.build(with: FormItemViewBuilder())
        itemView.accessibilityIdentifier = item.identifier
        return itemView
    }
}
