//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// The interface of the delegate of an item view.
/// :nodoc:
public protocol FormItemViewDelegate: AnyObject {}

/// A view representing a form item.
/// :nodoc:
open class FormItemView<ItemType: FormItem>: UIView, AnyFormItemView {
    
    /// The item represented by the view.
    public let item: ItemType
    
    /// The delegate of the item view.
    public weak var delegate: FormItemViewDelegate?
    
    /// Initializes the form item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: ItemType) {
        self.item = item
        
        super.init(frame: .zero)
        
        preservesSuperviewLayoutMargins = true
    }
    
    /// :nodoc:
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The array of item views embedded in the current item view.
    /// Subclasses can override this to return any item views they embed.
    open var childItemViews: [AnyFormItemView] {
        return []
    }
    
}

/// A type-erased form item view.
/// :nodoc:
public protocol AnyFormItemView: UIView {
    
    /// The delegate of the item view.
    var delegate: FormItemViewDelegate? { get set }
    
    /// The embedding item view of the current item view.
    var parentItemView: AnyFormItemView? { get }
    
    /// The array of item views embedded in the current item view.
    var childItemViews: [AnyFormItemView] { get }
    
}

/// :nodoc:
public extension AnyFormItemView {
    
    /// The embedding item view of the current item view.
    var parentItemView: AnyFormItemView? {
        guard let superview = superview else { return nil }
        let superviews = sequence(first: superview, next: { $0.superview })
        
        return superviews.first { $0 is AnyFormItemView } as? AnyFormItemView
    }
    
}
