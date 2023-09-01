//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A form item that represents a segmented control.
@_spi(AdyenInternal)
public final class FormSegmentedControlItem: FormItem {

    public var subitems: [FormItem] = []

    public var identifier: String?

    /// The style of the segmented control.
    public var style: SegmentedControlStyle

    /// A closure that will be invoked when a segmented control index is changed.
    public var selectionHandler: ((_ selectedIndex: Int) -> Void)?

    public init(items: [String], style: SegmentedControlStyle, identifier: String? = nil) {
        self.items = items
        self.style = style
    }

    // The segmented control items.
    private var items: [String]

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let segmentedControl = ADYSegmentedControl(items: items)
        segmentedControl.accessibilityIdentifier = identifier
        segmentedControl.backgroundColor = style.backgroundColor
        segmentedControl.tintColor = style.tintColor
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        segmentedControl.adyen.round(using: style.textStyle.cornerRounding)
        return segmentedControl
    }

    @objc private func segmentAction(_ segmentedControl: UISegmentedControl) {
        selectionHandler?(segmentedControl.selectedSegmentIndex)
    }
}

class ADYSegmentedControl: UISegmentedControl, AnyFormItemView {

    public var childItemViews: [AnyFormItemView] { [] }

    public func reset() { /* Do nothing */ }
}
