//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

/// A form item that represents a search bar button.
package final class FormSearchButtonItem: FormItem {

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    package var subitems: [FormItem] = []

    /// Indicates the item's UI styling.
    package let style: ViewStyle

    package var identifier: String?

    /// The title of the button.
    @AdyenObservable(nil) package var placeholder: String?

    /// A closure that will be invoked when a button is selected.
    package let selectionHandler: () -> Void

    /// Initializes the button item.
    ///
    /// - Parameter placeholder: The search bar placeholder
    /// - Parameter style: The style of the search bar
    /// - Parameter selectionHandler: A closure that will be invoked when a button is selected.
    package init(
        placeholder: String,
        style: ViewStyle,
        identifier: String,
        selectionHandler: @escaping () -> Void
    ) {
        self.selectionHandler = selectionHandler
        self.style = style
        self.identifier = identifier
        self.placeholder = placeholder
    }
    
    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
