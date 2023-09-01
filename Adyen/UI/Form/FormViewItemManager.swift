//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Manages the form items and their views.
final class FormViewItemManager {
    
    // MARK: - Items

    private(set) var topLevelItem: [FormItem] = []
    
    /// The flat list of all items managed by the item manager.
    var flatItems: [FormItem] {
        topLevelItem.flatMap(\.flatSubitems)
    }

    /// Appends an item to the list of managed items.
    ///
    /// - Parameters:
    ///   - item: The item to append.
    /// - Returns: The view instance correspondent to a selected item.
    @discardableResult func append<ItemType: FormItem>(_ item: ItemType) -> AnyFormItemView {
        topLevelItem.append(item)
        
        let itemView = newItemView(for: item)
        topLevelItemViews.append(itemView)

        return itemView
    }
    
    // MARK: - Item Views
    
    /// The item views managed by the item manager.
    /// Due to a compiler bug, we can't set this to be of type [AnyFormItem].
    private(set) var topLevelItemViews: [AnyFormItemView] = []

    /// The item views managed by the item manager, including nested item views.
    var flatItemViews: [AnyFormItemView] {
        topLevelItemViews.flatMap(\.flatSubitemViews)
    }

    private func newItemView<ItemType: FormItem>(for item: ItemType) -> AnyFormItemView {
        item.build(with: FormItemViewBuilder())
    }
    
}
