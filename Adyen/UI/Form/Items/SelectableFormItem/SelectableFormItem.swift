//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Simple form item that represent a single selectable element.
@_spi(AdyenInternal)
public class SelectableFormItem: FormItem {

    public var subitems: [FormItem] = []

    /// The title of the item.
    public var title: String

    /// The image url  to display the icon
    public var imageUrl: URL?

    /// Determines whether the item is currently the selected one.
    @AdyenObservable(false) public var isSelected: Bool

    /// The handler to invoke when the item is selected.
    public var selectionHandler: (() -> Void)?

    /// The `accessibilityIdentifier` to be used on the `SelectableFormItem`
    public var identifier: String?

    /// The `accessibilityLabel` to be used on the ``SelectableFormItem``
    public let accessibilityLabel: String

    /// The selectable item style.
    public let style: SelectableFormItemStyle

    public var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

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
    public init(
        title: String,
        imageUrl: URL? = nil,
        isSelected: Bool = false,
        style: SelectableFormItemStyle,
        identifier: String? = nil,
        accessibilityLabel: String? = nil,
        selectionHandler: (() -> Void)? = nil
    ) {
        self.title = title
        self.imageUrl = imageUrl
        self.style = style
        self.identifier = identifier
        self.accessibilityLabel = accessibilityLabel ?? title
        self.selectionHandler = selectionHandler
        self.isSelected = isSelected
    }

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
