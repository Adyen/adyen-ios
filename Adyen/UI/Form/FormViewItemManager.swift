//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Manages the form items and their views.
internal final class FormViewItemManager {
    
    /// The delegate of the item views created by the manager.
    internal private(set) weak var itemViewDelegate: FormItemViewDelegate?
    
    /// Initializes the item manager.
    ///
    /// - Parameter itemViewDelegate: The delegate of the item views created by the manager.
    internal init(itemViewDelegate: FormItemViewDelegate) {
        self.itemViewDelegate = itemViewDelegate
    }
    
    // MARK: - Items
    
    /// The items managed by the item manager.
    internal private(set) var items = [FormItem]()
    
    /// Appends an item to the list of managed items.
    ///
    /// - Parameters:
    ///   - item: The item to append.
    ///   - itemViewType: Optionally, the item view type to use for this item.
    ///                   When none is specified, the default will be used.
    internal func append<T: FormItem>(_ item: T, using itemViewType: FormItemView<T>.Type?) {
        items.append(item)
        
        let itemView = newItemView(for: item, using: itemViewType)
        itemViews.append(itemView)
        allItemViews.append(itemView)
        allItemViews.append(contentsOf: itemView.childItemViews)
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
    private var allItemViews = [AnyFormItemView]()
    
    /// Returns the item view for the given item.
    ///
    /// - Parameter item: The item to retrieve the item view for.
    /// - Returns: The item view for the given item.
    internal func itemView<T: FormItem>(for item: T) -> FormItemView<T> {
        return itemViews[index(of: item)] as! FormItemView<T> // swiftlint:disable:this force_cast
    }
    
    /// Returns all the item views of the requested type.
    /// This will also search for nested item views.
    ///
    /// - Parameter type: The type of item views to return.
    /// - Returns: All item views of the requested type.
    internal func itemViews<T: FormItem, U: FormItemView<T>>(ofType type: U.Type) -> [U] {
        return allItemViews.compactMap { $0 as? U }
    }
    
    private func newItemView<T: FormItem>(for item: T, using itemViewType: FormItemView<T>.Type?) -> FormItemView<T> {
        let itemViewType = itemViewType ?? self.itemViewType(for: item)
        let itemView = itemViewType.init(item: item)
        itemView.delegate = itemViewDelegate
        itemView.childItemViews.forEach { $0.delegate = itemViewDelegate }
        
        return itemView
    }
    
    private func itemViewType<T: FormItem>(for item: T) -> FormItemView<T>.Type {
        let itemViewType: Any
        
        switch item {
        case is FormHeaderItem:
            itemViewType = FormHeaderItemView.self
        case is FormFooterItem:
            itemViewType = FormFooterItemView.self
        case is FormTextItem:
            itemViewType = FormTextItemView.self
        case is FormSwitchItem:
            itemViewType = FormSwitchItemView.self
        case is FormSplitTextItem:
            itemViewType = FormSplitTextItemView.self
        default:
            fatalError("No view type known for given item.")
        }
        
        // swiftlint:disable:next force_cast
        return itemViewType as! FormItemView<T>.Type
    }
    
}
