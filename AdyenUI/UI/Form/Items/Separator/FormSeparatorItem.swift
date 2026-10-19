//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A form item that represents a separator line.
package final class FormSeparatorItem: FormItem {

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    package var subitems: [FormItem] = []

    /// Indicates the line color.
    package let color: UIColor

    package var identifier: String?

    /// Initializes the separator item.
    ///
    /// - Parameter style: Any `ViewStyle` UI style.
    package init(color: UIColor) {
        self.color = color
    }
    
    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
