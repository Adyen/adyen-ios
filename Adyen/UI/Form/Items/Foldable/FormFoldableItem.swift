//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item that presents single FormItem, that could be hide or showed dynamicaly.
/// :nodoc:
public final class FormFoldableItem: CompoundFormItem {

    internal let item: FormItem

    /// Indicates the `FormFoldableItem` UI styling.
    public let style: ViewStyle

    /// :nodoc:
    public var identifier: String?

    /// :nodoc:
    public var subitems: [FormItem] { [item] }

    /// The observable of the goups visibility.
    @Observable(false) public var isFolded: Bool

    /// Initializes foldable items group.
    ///
    /// - Parameter items: The item to show or hide.
    /// - Parameter style: The `FormSplitItemView` UI style.
    public init(item: FormItem, style: ViewStyle) {
        self.item = item
        self.style = style
    }

    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }

}
