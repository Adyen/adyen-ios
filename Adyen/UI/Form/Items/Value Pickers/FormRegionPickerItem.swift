//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Describes a single text picker item in the list of selectable items.
/// :nodoc:
public typealias RegionPickerItem = BasePickerElement<Region>

/// Describes a picker item.
/// :nodoc:
public final class FormRegionPickerItem: BaseFormValuePickerItem<Region> {

    internal init(initValue: Region, selectableValues: [Region], style: FormTextItemStyle) {
        super.init(initValue: RegionPickerItem(identifier: initValue.identifier, item: initValue),
                   selectableValues: selectableValues.map { RegionPickerItem(identifier: $0.identifier, item: $0) },
                   style: style)
    }

    // :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

internal final class FormRegionPickerItemView: BaseFormValuePickerItemView<Region> {

    override internal func initialize() {
        let stackView = UIStackView(arrangedSubviews: [inputControl])
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.adyen.anchor(inside: self)
    }

}
