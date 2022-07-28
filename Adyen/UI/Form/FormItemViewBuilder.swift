//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds different types of `FormItemView's`  from the corresponding concrete `FormItem`.
@_spi(AdyenInternal)
public struct FormItemViewBuilder {
    
    /// Builds `FormToggleItemView` from `FormToggleItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormToggleItem) -> FormItemView<FormToggleItem> {
        FormToggleItemView(item: item)
    }
    
    /// Builds `FormSplitItemView` from `FormSplitItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormSplitItem) -> FormItemView<FormSplitItem> {
        FormSplitItemView(item: item)
    }
    
    /// Builds `PhoneNumberItemView` from `PhoneNumberItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormPhoneNumberItem) -> FormItemView<FormPhoneNumberItem> {
        FormPhoneNumberItemView(item: item)
    }
    
    /// Builds `FormPhoneExtensionPickerItemView` from `FormPhoneExtensionPickerItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormPhoneExtensionPickerItem) -> BaseFormPickerItemView<PhoneExtension> {
        FormPhoneExtensionPickerItemView(item: item)
    }

    /// Builds `FormRegionPickerItemView` from `FormRegionPickerItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormRegionPickerItem) -> BaseFormPickerItemView<Region> {
        FormRegionPickerItemView(item: item)
    }

    /// Builds `FormIssuerPickerItemView` from `FormIssuerPickerItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormIssuersPickerItem) -> BaseFormPickerItemView<Issuer> {
        FormIssuersPickerItemView(item: item)
    }

    /// Builds `FormTextInputItemView` from `FormTextInputItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormTextInputItem) -> FormItemView<FormTextInputItem> {
        FormTextInputItemView(item: item)
    }
    
    /// Builds `ListItemView` from `ListItem`.
    @_spi(AdyenInternal)
    public func build(with item: ListItem) -> ListItemView {
        let listView = ListItemView()
        listView.item = item
        return listView
    }
    
    /// Builds `FormButtonItemView` from `FormButtonItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormButtonItem) -> FormItemView<FormButtonItem> {
        FormButtonItemView(item: item)
    }
    
    /// Builds `FormSeparatorItemView` from `FormSeparatorItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormSeparatorItem) -> FormItemView<FormSeparatorItem> {
        FormSeparatorItemView(item: item)
    }

    /// Builds `FormErrorItemView` from `FormErrorItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormErrorItem) -> FormItemView<FormErrorItem> {
        FormErrorItemView(item: item)
    }
    
    /// Builds `FormVerticalStackItemView` from `FormAddressItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormAddressItem) -> FormItemView<FormAddressItem> {
        FormVerticalStackItemView(item: item)
    }

    /// Builds `FormSpacerItemView` from `FormSpacerItem`.
    @_spi(AdyenInternal)
    public func build(with item: FormSpacerItem) -> FormItemView<FormSpacerItem> {
        FormSpacerItemView(item: item)
    }
    
    @_spi(AdyenInternal)
    public func build(with item: FormPostalCodeItem) -> FormItemView<FormPostalCodeItem> {
        FormTextItemView(item: item)
    }

    @_spi(AdyenInternal)
    public static func build(_ item: FormItem) -> AnyFormItemView {
        let itemView = item.build(with: FormItemViewBuilder())
        itemView.accessibilityIdentifier = item.identifier
        return itemView
    }
}
