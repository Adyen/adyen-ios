//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds different types of `FormItemView's`  from the corresponding concrete `FormItem`.
@_spi(AdyenInternal)
public struct FormItemViewBuilder {

    /// The theme to use for building views.
    package let theme: AdyenTheme

    /// Initializes the form item view builder.
    /// - Parameter theme: The theme to use for building views. Defaults to `.default`.
    package init(theme: AdyenTheme = .default) {
        self.theme = theme
    }

    /// Builds `FormToggleItemView` from `FormToggleItem`.
    package func build(with item: FormToggleItem) -> FormItemView<FormToggleItem> {
        FormToggleItemView(item: item, theme: theme)
    }

    /// Builds `FormSplitItemView` from `FormSplitItem`.
    package func build(with item: FormSplitItem) -> FormItemView<FormSplitItem> {
        FormSplitItemView(item: item)
    }

    /// Builds `PhoneNumberItemView` from `PhoneNumberItem`.
    package func build(with item: FormPhoneNumberItem) -> FormItemView<FormPhoneNumberItem> {
        FormPhoneNumberItemView(item: item, theme: theme)
    }

    /// Builds `FormIssuerPickerItemView` from `FormIssuerPickerItem`.
    package func build<Value: CustomStringConvertible>(with item: BaseFormPickerItem<Value>)
        -> BaseFormPickerItemView<Value> {
        BaseFormPickerItemView(item: item, theme: theme)
    }

    /// Builds `FormTextInputItemView` from `FormTextInputItem`.
    package func build(with item: FormTextInputItem) -> FormItemView<FormTextInputItem> {
        FormTextInputItemView(item: item, theme: theme)
    }

    /// Builds `ListItemView` from `ListItem`.
    package func build(with item: ListItem) -> ListItemView {
        let listView = ListItemView()
        listView.item = item
        return listView
    }

    /// Builds `SelectableFormItemView` from `SelectableFormItem`.
    package func build(with item: SelectableFormItem) -> FormItemView<SelectableFormItem> {
        SelectableFormItemView(item: item)
    }

    /// Builds `FormButtonItemView` from `FormButtonItem`.
    package func build(with item: FormButtonItem) -> FormItemView<FormButtonItem> {
        FormButtonItemView(item: item, theme: theme)
    }

    /// Builds `FormImageView` from `FormImageItem`.
    package func build(with item: FormImageItem) -> FormItemView<FormImageItem> {
        FormImageView(item: item)
    }

    /// Builds `FormSeparatorItemView` from `FormSeparatorItem`.
    package func build(with item: FormSeparatorItem) -> FormItemView<FormSeparatorItem> {
        FormSeparatorItemView(item: item, theme: theme)
    }

    /// Builds `FormErrorItemView` from `FormErrorItem`.
    package func build(with item: FormErrorItem) -> FormItemView<FormErrorItem> {
        FormErrorItemView(item: item)
    }

    /// Builds `FormVerticalStackItemView` from `FormAddressItem`.
    package func build(with item: FormAddressItem) -> FormItemView<FormAddressItem> {
        FormVerticalStackItemView(item: item, theme: theme)
    }

    /// Builds `FormSpacerItemView` from `FormSpacerItem`.
    package func build(with item: FormSpacerItem) -> FormItemView<FormSpacerItem> {
        FormSpacerItemView(item: item)
    }

    /// Builds `FormTextItemView` from `FormPostalCodeItem`.
    package func build(with item: FormPostalCodeItem) -> FormItemView<FormPostalCodeItem> {
        FormTextItemView(item: item, theme: theme)
    }

    /// Builds `FormSearchButtonItemView` from `FormSearchButtonItem`.
    package func build(with item: FormSearchButtonItem) -> FormItemView<FormSearchButtonItem> {
        FormSearchButtonItemView(item: item)
    }

    /// Builds `FormAddressPickerItemView` from `FormAddressPickerItem`.
    package func build(with item: FormAddressPickerItem) -> FormItemView<FormAddressPickerItem> {
        FormAddressPickerItemView(item: item, theme: theme)
    }

    /// Builds `FormPickerItemView` from `FormPickerItem`.
    package func build<Value>(with item: FormPickerItem<Value>) -> FormItemView<
        FormPickerItem<Value>
    > {
        FormPickerItemView(item: item, theme: theme)
    }

    /// Builds `FormPhoneExtensionPickerItemView` from `FormPhoneExtensionPickerItem`.
    package func build(with item: FormPhoneExtensionPickerItem) -> FormPhoneExtensionPickerItemView {
        FormPhoneExtensionPickerItemView(item: item)
    }

    @_spi(AdyenInternal)
    public static func build(_ item: FormItem) -> AnyFormItemView {
        let itemView = item.build(with: FormItemViewBuilder())
        itemView.accessibilityIdentifier = item.identifier
        return itemView
    }
}
