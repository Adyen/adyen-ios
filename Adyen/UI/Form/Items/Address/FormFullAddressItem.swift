//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Abstract class for form item to show address form.
/// :nodoc:
open class AnyAddressItem: FormItem, CompoundFormItem {

    /// :nodoc:
    open var subitems: [FormItem] = []

    /// :nodoc:
    open var identifier: String?

    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

/// A full address form, sutable for all countries.
/// :nodoc:
public final class GenericFormAddressItem: AnyAddressItem {

    /// Indicates the `FormSplitItemView` UI styling.
    public let style: FormComponentStyle

    /// :nodoc:
    public var subitems: [FormItem]

    /// Initializes the split text item.
    ///
    /// - Parameter items: The items displayed side-by-side. Must be two.
    /// - Parameter style: The `FormSplitItemView` UI style.
    public init(style: FormComponentStyle) {
        self.style = style
        subitems = [headerItem, countrySelecItem, cityTextItem]
    }

    internal lazy var headerItem: FormItem = {
        let item = FormLabelItem(text: "Billing Address", style: style.sectionHeader)
        return item
    }()

    internal lazy var countrySelecItem: FormItem = {
        let item = FormLabelItem(text: "Billing Address", style: style.sectionHeader)
        return item
    }()

    internal lazy var cityTextItem: FormItem = {
        let item = FormLabelItem(text: "Billing Address", style: style.sectionHeader)
        return item
    }()

    /// :nodoc:
    public override func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
