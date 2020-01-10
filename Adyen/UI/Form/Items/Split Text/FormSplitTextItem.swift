//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item in which two text items are shown side-by-side.
/// :nodoc:
public final class FormSplitTextItem: FormItem {
    
    /// Indicates the `FormSplitTextItemView` UI styling.
    public let style: ViewStyle
    
    /// :nodoc:
    public var identifier: String?
    
    /// The text item displayed on the left side.
    public var leftItem: FormTextItem
    
    /// The text item displayed on the right side.
    public var rightItem: FormTextItem
    
    /// Initializes the split text item.
    ///
    /// - Parameter items: The items displayed side-by-side. Must be two.
    /// - Parameter style: The `FormSplitTextItemView` UI style.
    public init(items: [FormTextItem], style: ViewStyle) {
        assert(items.count == 2)
        self.leftItem = items[0]
        self.rightItem = items[1]
        self.style = style
    }
    
}
