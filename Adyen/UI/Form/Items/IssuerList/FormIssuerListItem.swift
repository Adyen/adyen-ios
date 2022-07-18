//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a Issuer list item.
@_spi(AdyenInternal)
public final class FormIssuerListItem: FormTextItem {

    // The issuer picker item.
    internal let issuerItem: FormIssuersPickerItem

    /// Initializes the issuer list item.
    ///
    /// - Parameter selectableValues: The list of values to select from.
    /// - Parameter style: The `FormTextItemStyle` UI style.
    /// - Parameter localizationParameters: Parameters for custom localization, leave it nil to use the default parameters.
    public init(preselectedValue: IssuerPickerItem,
                selectableValues: [IssuerPickerItem],
                style: FormTextItemStyle,
                localizationParameters: LocalizationParameters? = nil) {
        issuerItem = FormIssuersPickerItem.init(preselectedValue: preselectedValue,
                                                selectableValues: selectableValues,
                                                style: style)
        super.init(style: style)
        issuerItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self, postfix: "issuerPickerItem")
    }

    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
