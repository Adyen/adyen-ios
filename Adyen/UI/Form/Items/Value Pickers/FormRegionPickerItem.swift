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
public final class FormRegionPickerItem: BaseFormPickerItem<Region> {

    internal init(preselectedValue: Region, selectableValues: [Region], style: FormTextItemStyle) {
        super.init(preselectedValue: RegionPickerItem(identifier: preselectedValue.identifier, element: preselectedValue),
                   selectableValues: selectableValues.map { RegionPickerItem(identifier: $0.identifier, element: $0) },
                   style: style)
    }

    // :nodoc:
    override public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

internal final class FormRegionPickerItemView: BaseFormPickerItemView<Region> {

    /// :nodoc:
    public lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = item.style.title.font
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = item.style.title.color
        titleLabel.textAlignment = item.style.title.textAlignment
        titleLabel.backgroundColor = item.style.title.backgroundColor
        titleLabel.text = item.title
        titleLabel.isAccessibilityElement = false
        titleLabel.accessibilityIdentifier = item.identifier.map { ViewIdentifierBuilder.build(scopeInstance: $0, postfix: "titleLabel") }

        return titleLabel
    }()

    override internal func initialize() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, inputControl])
        stackView.axis = .vertical
        stackView.spacing = 8
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.preservesSuperviewLayoutMargins = true
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.adyen.anchor(inside: self)
    }

}
