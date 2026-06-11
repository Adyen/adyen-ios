//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A form item in which two items are shown side-by-side horizontally.
package final class FormSplitItem: FormItem {

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    internal var leftItem: FormItem

    internal var rightItem: FormItem
    
    /// Indicates the `FormSplitItemView` UI styling.
    package let style: ViewStyle

    package var identifier: String?

    package var subitems: [FormItem] {
        [leftItem, rightItem]
    }
    
    /// Initializes the split text item.
    ///
    /// - Parameter items: The items displayed side-by-side. Must be two.
    /// - Parameter style: The `FormSplitItemView` UI style.
    package init(items: FormItem..., style: ViewStyle) {
        assert(items.count == 2)
        self.leftItem = items[0]
        self.rightItem = items[1]
        self.style = style
    }
    
    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
