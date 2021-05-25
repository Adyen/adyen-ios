//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A space form item in terms of number of layout margins.
/// :nodoc:
public final class FormSpacerItem: FormItem {

    /// :nodoc:
    public var identifier: String?

    /// :nodoc:
    public let subitems: [FormItem] = []

    /// Indicates number of layout margins.
    /// :nodoc:
    public let standardSpaceMultiplier: Int

    /// Initializes a `FormSpacerItem`.
    ///
    /// - Parameter standardSpaceMultiplier: The number of layout margins.
    /// :nodoc:
    public init(numberOfSpaces: Int = 1) {
        self.standardSpaceMultiplier = numberOfSpaces
    }

    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
}
