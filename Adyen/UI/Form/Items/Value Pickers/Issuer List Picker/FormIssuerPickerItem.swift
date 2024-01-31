//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

@_documentation(visibility: internal)
public typealias IssuerPickerItem = BasePickerElement<Issuer>

@_documentation(visibility: internal)
public final class FormIssuersPickerItem: BaseFormPickerItem<Issuer> {

    override public init(preselectedValue: IssuerPickerItem, selectableValues: [IssuerPickerItem], style: FormTextItemStyle) {
        AdyenAssertion.assert(message: "selectableValues should be greater than 0", condition: selectableValues.count <= 0)
        super.init(preselectedValue: preselectedValue, selectableValues: selectableValues, style: style)
    }

    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
