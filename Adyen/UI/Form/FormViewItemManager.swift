//
// Copyright (c) 2020 Adyen N.V.
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
    @discardableResult internal func append<T: FormItem>(_ item: T) -> AnyFormItemView {
        items.append(item)
        
        let itemView = newItemView(for: item)
        itemViews.append(itemView)
        allItemViews.append(itemView)
        allItemViews.append(contentsOf: itemView.childItemViews)

        return itemView
    }
    
    private func index(of item: FormItem) -> Int {
        let index = items.firstIndex {
            $0 === item
        }
        
        if let index = index {
            return index
        } else {
            fatalError("Provided item is not managed by receiver.")
        }
    }
    
    // MARK: - Item Views
    
    /// The item views managed by the item manager.
    /// Due to a compiler bug, we can't set this to be of type [AnyFormItem].
    internal private(set) var itemViews = [UIView]()
    
    /// The item views managed by the item manager, including nested item views.
    internal var allItemViews = [AnyFormItemView]()
    
    /// Returns the item view for the given item.
    ///
    /// - Parameter item: The item to retrieve the item view for.
    /// - Returns: The item view for the given item or nil if item not found.
    internal func itemView<T: FormItem>(for item: T) -> FormItemView<T>? {
        itemViews[index(of: item)] as? FormItemView<T>
    }
    
    private func newItemView<T: FormItem>(for item: T) -> AnyFormItemView {
        item.build(with: FormItemViewBuilder())
    }
    
}
