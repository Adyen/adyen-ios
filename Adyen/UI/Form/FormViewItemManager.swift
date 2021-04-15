//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Manages the form items and their views.
internal final class FormViewItemManager {
    
    // MARK: - Items
    
    /// The items managed by the item manager.
    internal private(set) var items = [FormItem]()
    
    /// Appends an item to the list of managed items.
    ///
    /// - Parameters:
    ///   - item: The item to append.
    /// - Returns: The view instance correspondent to a selected item.
    @discardableResult internal func append<ItemType: FormItem>(_ item: ItemType) -> AnyFormItemView {
        items.append(item)
        
        let itemView = newItemView(for: item)
        itemViews.append(itemView)
        allItemViews.append(itemView)
        allItemViews.append(contentsOf: itemView.childItemViews)

        return itemView
    }
    
    // MARK: - Item Views
    
    /// The item views managed by the item manager.
    /// Due to a compiler bug, we can't set this to be of type [AnyFormItem].
    internal private(set) var itemViews = [UIView]()
    
    /// The item views managed by the item manager, including nested item views.
    internal var allItemViews = [AnyFormItemView]()
    
    private func newItemView<ItemType: FormItem>(for item: ItemType) -> AnyFormItemView {
        item.build(with: FormItemViewBuilder())
    }
    
}
