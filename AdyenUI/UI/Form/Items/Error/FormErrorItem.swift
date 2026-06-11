//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A form item that represents an error.
package final class FormErrorItem: FormItem {

    /// Indicates the error message.
    @AdyenObservable(nil) package var message: String?

    /// The error icon name.
    package let iconName: String

    /// The error item style.
    package let style: FormErrorItemStyle

    package var identifier: String?

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(true)

    package var subitems: [FormItem] = []

    package init(message: String? = nil, iconName: String = "error", style: FormErrorItemStyle = FormErrorItemStyle()) {
        self.iconName = iconName
        self.style = style
        self.message = message
    }

    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
