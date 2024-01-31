//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

/// A view representing a form item.
@_documentation(visibility: internal)
open class FormItemView<ItemType: FormItem>: UIView, AnyFormItemView, AdyenObserver {
    
    /// The item represented by the view.
    public let item: ItemType
    
    /// Initializes the form item view.
    ///
    /// - Parameter item: The item represented by the view.
    public required init(item: ItemType) {
        self.item = item
        
        super.init(frame: .zero)
        accessibilityIdentifier = item.identifier
        preservesSuperviewLayoutMargins = true
    }
    
    @available(*, unavailable)
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// The array of item views embedded in the current item view.
    /// Subclasses can override this to return any item views they embed.
    open var childItemViews: [AnyFormItemView] {
        []
    }
    
    public func reset() { /* Do nothing */ }
    
}

/// A type-erased form item view.
@_documentation(visibility: internal)
public protocol AnyFormItemView: UIView {
    
    /// The embedding item view of the current item view.
    var parentItemView: AnyFormItemView? { get }
    
    /// The array of item views embedded in the current item view.
    var childItemViews: [AnyFormItemView] { get }
    
    func reset()
    
}

@_documentation(visibility: internal)
public extension AnyFormItemView {
    
    /// The embedding item view of the current item view.
    var parentItemView: AnyFormItemView? {
        guard let superview else { return nil }
        let superviews = sequence(first: superview, next: { $0.superview })
        
        return superviews.first { $0 is AnyFormItemView } as? AnyFormItemView
    }

    /// The flat list of all sub-itemViews.
    var flatSubitemViews: [AnyFormItemView] {
        [self] + childItemViews.flatMap(\.flatSubitemViews)
    }
    
}
