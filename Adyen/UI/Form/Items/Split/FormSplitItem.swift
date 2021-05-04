//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item in which two items are shown side-by-side horizontally.
/// :nodoc:
public final class FormSplitItem: FormItem {

    internal var leftItem: FormItem

    internal var rightItem: FormItem
    
    /// Indicates the `FormSplitItemView` UI styling.
    public let style: ViewStyle
    
    /// :nodoc:
    public var identifier: String?
    
    /// :nodoc:
    public var subitems: [FormItem] {
        [leftItem, rightItem]
    }
    
    /// Initializes the split text item.
    ///
    /// - Parameter items: The items displayed side-by-side. Must be two.
    /// - Parameter style: The `FormSplitItemView` UI style.
    public init(items: FormItem..., style: ViewStyle) {
        assert(items.count == 2)
        self.leftItem = items[0]
        self.rightItem = items[1]
        self.style = style
    }
    
    /// :nodoc:
    public func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        builder.build(with: self)
    }
    
}
