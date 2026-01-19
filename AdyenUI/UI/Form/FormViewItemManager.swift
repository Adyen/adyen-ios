//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// Manages the form items and their views.
internal final class FormViewItemManager {
    
    // MARK: - Properties
    
    private let theme: AdyenTheme
    
    // MARK: - Items

    internal private(set) var topLevelItem: [FormItem] = []
    
    /// The flat list of all items managed by the item manager.
    internal var flatItems: [FormItem] {
        topLevelItem.flatMap(\.flatSubitems)
    }

    /// Initializes the FormViewItemManager with a theme.
    /// - Parameter theme: The theme to use for styling views.
    internal init(theme: AdyenTheme) {
        self.theme = theme
    }
    
    /// Appends an item to the list of managed items.
    ///
    /// - Parameters:
    ///   - item: The item to append.
    /// - Returns: The view instance correspondent to a selected item.
    @discardableResult internal func append(_ item: some FormItem) -> AnyFormItemView {
        topLevelItem.append(item)
        
        let itemView = newItemView(for: item)
        topLevelItemViews.append(itemView)

        return itemView
    }
    
    // MARK: - Item Views
    
    /// The item views managed by the item manager.
    /// Due to a compiler bug, we can't set this to be of type [AnyFormItem].
    internal private(set) var topLevelItemViews: [AnyFormItemView] = []

    /// The item views managed by the item manager, including nested item views.
    internal var flatItemViews: [AnyFormItemView] {
        topLevelItemViews.flatMap(\.flatSubitemViews)
    }

    private func newItemView(for item: some FormItem) -> AnyFormItemView {
        item.build(with: FormItemViewBuilder(theme: theme))
    }
}
