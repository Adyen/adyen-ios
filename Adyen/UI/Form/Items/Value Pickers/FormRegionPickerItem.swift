//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Describes a single text picker item in the list of selectable items.
/// :nodoc:
public typealias RegionPickerItem = BasePickerElement<Region>

/// Describes a picker item.
/// :nodoc:
public final class FormRegionPickerItem: BaseFormPickerItem<Region> {

    internal init(preselectedValue: Region, selectableValues: [Region], style: FormTextItemStyle) {
        super.init(preselectedValue: Self.pickerElement(from: preselectedValue),
                   selectableValues: selectableValues.map(Self.pickerElement),
                   style: style)
    }

    // :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

    private static func pickerElement(from region: Region) -> RegionPickerItem {
        RegionPickerItem(identifier: region.identifier, element: region)
    }

}

internal final class FormRegionPickerItemView: BaseFormPickerItemView<Region> {

    override internal func initialize() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, inputControl])
        stackView.axis = .vertical
        stackView.spacing = 5.5
        addSubview(stackView)
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.adyen.anchor(inside: self)
    }

}
