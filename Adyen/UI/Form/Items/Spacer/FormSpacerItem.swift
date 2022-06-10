//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A space form item in terms of number of layout margins.
@_spi(AdyenInternal)
public final class FormSpacerItem: FormItem {

    public var identifier: String?

    public let subitems: [FormItem] = []

    /// Indicates number of layout margins.
    public let standardSpaceMultiplier: Int

    /// Initializes a `FormSpacerItem`.
    ///
    /// - Parameter standardSpaceMultiplier: The number of layout margins.
    public init(numberOfSpaces: Int = 1) {
        self.standardSpaceMultiplier = numberOfSpaces
    }

    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
