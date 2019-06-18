//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A form item in which two text items are shown side-by-side.
/// :nodoc:
public final class FormSplitTextItem: FormItem {
    
    /// The text item displayed on the left side.
    public var leftItem: FormTextItem
    
    /// The text item displayed on the right side.
    public var rightItem: FormTextItem
    
    /// Initializes the split text item.
    ///
    /// - Parameter items: The items displayed side-by-side. Must be two.
    public init(items: [FormTextItem]) {
        assert(items.count == 2)
        leftItem = items[0]
        rightItem = items[1]
    }
    
}
