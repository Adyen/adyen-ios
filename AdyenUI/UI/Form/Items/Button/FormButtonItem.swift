//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A form item that represents a single button with a spinner.
package final class FormButtonItem: FormItem {

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    package var subitems: [FormItem] = []

    package var style: FormButtonItemStyle

    /// Indicates the item's UI styling.
    internal var buttonStyle: AdyenButtonStyle = AdyenButtonStyles.default.primary

    package var identifier: String?

    /// The title of the button.
    @AdyenObservable(nil) package var title: String?

    /// The observable of the button indicator activity.
    @AdyenObservable(false) package var showsActivityIndicator: Bool

    /// The observable of the button's availability status.
    @AdyenObservable(true) package var enabled: Bool

    /// A closure that will be invoked when a button is selected.
    package var buttonSelectionHandler: (() -> Void)?

    package init(style: FormButtonItemStyle) {
        self.style = style
    }

    /// Initializes the button item.
    ///
    /// - Parameter style: The item's UI style.
    package init(buttonStyle: AdyenButtonStyle = AdyenButtonStyle.primary(for: .default)) {
        self.buttonStyle = buttonStyle
        self.style = .init(button: .init(title: .init(font: .preferredFont(forTextStyle: .body), color: .red)))
    }
    
    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
