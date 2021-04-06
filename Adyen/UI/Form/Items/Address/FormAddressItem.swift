//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item to show address form.
/// :nodoc:
public final class FormFullAddressItem: CompoundFormItem {

    /// Indicates the `FormSplitItemView` UI styling.
    public let style: FormComponentStyle

    /// :nodoc:
    public var identifier: String?

    /// :nodoc:
    public var subitems: [FormItem] {
        [headerItem, countrySelecItem]
    }

    /// Initializes the split text item.
    ///
    /// - Parameter items: The items displayed side-by-side. Must be two.
    /// - Parameter style: The `FormSplitItemView` UI style.
    public init(style: FormComponentStyle) {
        self.style = style
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
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
