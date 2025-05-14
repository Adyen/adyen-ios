//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import UIKit

/// CoBadged card form item.
internal final class FormCoBadgedCardItem: FormItem {

    internal var subitems: [FormItem] = []

    /// The title of the item.
    internal var title: String

    /// The subtitle of the item.
    internal var subtitle: String

    /// The array of selectable form items.
    @AdyenObservable([]) internal var selectableFormItems: [SelectableFormItem]

    /// The `accessibilityIdentifier` to be used on the `FormCoBadgedCardItem`
    internal var identifier: String?

    /// The `accessibilityLabel` to be used on the ``FormCoBadgedCardItem``
    internal let accessibilityLabel: String

    internal var isHidden: AdyenObservable<Bool> = AdyenObservable(true)

    /// The coBadged card item style.
    internal let style: FormCoBadgedCardItemStyle

    /// Initializes the FormCoBadged card item.
    ///
    /// - Parameters:
    ///   - title: The title of the coBadged card selection UI.
    ///   - subtitle: The subtitle of the coBadged card selection UI.
    ///   - selectableFormItems: The array of the selectableFormItems.
    ///   - style: The style of the coBadged card form item.
    ///   - identifier: The `accessibilityIdentifier` to be used on the `FormCoBadgedCardItem`
    ///   - accessibilityLabel: An optional custom `accessibilityLabel` to use.
    internal init(
        title: String,
        subtitle: String,
        selectableFormItems: [SelectableFormItem],
        style: FormCoBadgedCardItemStyle,
        identifier: String? = nil,
        accessibilityLabel: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.style = style
        self.identifier = identifier
        self.accessibilityLabel = accessibilityLabel ?? ""
        self.selectableFormItems = selectableFormItems
    }

    // MARK: - BuildableFormItem

    internal func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}

extension FormItemViewBuilder {
    internal func build(with item: FormCoBadgedCardItem) -> FormItemView<FormCoBadgedCardItem> {
        FormCoBadgedCardItemView(item: item)
    }
}
