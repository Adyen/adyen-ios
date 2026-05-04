//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// Simple form item that represent a single selectable element.
package class SelectableFormItem: FormItem {

    package var subitems: [FormItem] = []

    /// The title of the item.
    package var title: String

    /// The image url  to display the icon
    package var imageUrl: URL?

    /// Determines whether the item is currently the selected one.
    @AdyenObservable(false) package var isSelected: Bool

    /// The handler to invoke when the item is selected.
    package var selectionHandler: (() -> Void)?

    /// The `accessibilityIdentifier` to be used on the `SelectableFormItem`
    package var identifier: String?

    /// The `accessibilityLabel` to be used on the ``SelectableFormItem``
    package let accessibilityLabel: String

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    @AdyenObservable(true) package var isSeparatorViewShown: Bool

    /// Initializes the list item.
    ///
    /// - Parameters:
    ///   - title: The title of the item.
    ///   - imageUrl: The image url of the item icon.
    ///   - isSelected: The property to set selected item.
    ///   - style: The selectable item style.
    ///   - identifier: The `accessibilityIdentifier` to be used on the `SelectableFormItem`
    ///   - accessibilityLabel: An optional custom `accessibilityLabel` to use.
    ///   - selectionHandler: The closure to execute when an item is selected.
    package init(
        title: String,
        imageUrl: URL? = nil,
        isSelected: Bool = false,
        isSeparatorViewShown: Bool = true,
        identifier: String? = nil,
        accessibilityLabel: String? = nil,
        selectionHandler: (() -> Void)? = nil
    ) {
        self.title = title
        self.imageUrl = imageUrl
        self.identifier = identifier
        self.accessibilityLabel = accessibilityLabel ?? title
        self.selectionHandler = selectionHandler
        self.isSelected = isSelected
        self.isSeparatorViewShown = isSeparatorViewShown
    }

    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}

extension SelectableFormItem: Equatable {

    package static func == (lhs: SelectableFormItem, rhs: SelectableFormItem) -> Bool {
        lhs.title == rhs.title &&
            lhs.identifier == rhs.identifier
    }
}
