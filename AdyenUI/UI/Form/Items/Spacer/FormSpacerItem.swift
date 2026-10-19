//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// A space form item in terms of number of layout margins.
package final class FormSpacerItem: FormItem {

    package var isHidden: AdyenObservable<Bool> = AdyenObservable(false)

    package var identifier: String?

    package let subitems: [FormItem] = []

    /// Indicates number of layout margins.
    package let standardSpaceMultiplier: Int

    /// Initializes a `FormSpacerItem`.
    ///
    /// - Parameter standardSpaceMultiplier: The number of layout margins.
    package init(numberOfSpaces: Int = 1) {
        self.standardSpaceMultiplier = numberOfSpaces
    }

    package func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
