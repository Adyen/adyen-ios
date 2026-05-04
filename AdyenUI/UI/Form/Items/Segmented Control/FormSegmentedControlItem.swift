//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A form item that represents a segmented control.
package final class FormSegmentedControlItem: FormItem {

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    package var subitems: [FormItem] = []

    package var identifier: String?

    /// The style of the segmented control.
    package var style: SegmentedControlStyle

    /// A closure that will be invoked when a segmented control index is changed.
    package var selectionHandler: ((_ selectedIndex: Int) -> Void)?

    package init(
        items: [String],
        style: SegmentedControlStyle,
        identifier: String? = nil
    ) {
        self.items = items
        self.style = style
        self.identifier = identifier
    }

    /// The segmented control items.
    private var items: [String]

    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        let segmentedControl = ADYSegmentedControl(items: items)
        segmentedControl.accessibilityIdentifier = identifier
        segmentedControl.backgroundColor = style.backgroundColor
        segmentedControl.tintColor = style.tintColor
        segmentedControl.setTitleTextAttributes([NSAttributedString.Key.font: style.textStyle.font], for: .normal)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self, action: #selector(segmentAction), for: .valueChanged)
        segmentedControl.adyen.round(using: style.textStyle.cornerRounding)
        return segmentedControl
    }

    @objc private func segmentAction(_ segmentedControl: UISegmentedControl) {
        selectionHandler?(segmentedControl.selectedSegmentIndex)
    }
}

internal class ADYSegmentedControl: UISegmentedControl, AnyFormItemView {

    package var childItemViews: [AnyFormItemView] {
        []
    }
}
