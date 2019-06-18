//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import UIKit

internal extension UIBarButtonItem {
    
    /// Creates and returns a cancel bar button item with a selection handler.
    ///
    /// - Parameter selectionHandler: The handler to invoke when the button is selected.
    /// - Returns: A cancel bar button item.
    // swiftlint:disable:next explicit_acl
    static func cancel(withSelectionHandler selectionHandler: @escaping (() -> Void)) -> UIBarButtonItem {
        let wrapper = SelectionHandlerWrapper(selectionHandler: selectionHandler)
        let item = UIBarButtonItem(barButtonSystemItem: .cancel,
                                   target: wrapper,
                                   action: #selector(SelectionHandlerWrapper.invokeSelectionHandler))
        objc_setAssociatedObject(item, &AssociatedKeys.selectionHandlerWrapper, wrapper, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return item
    }
    
    private class SelectionHandlerWrapper {
        
        private let selectionHandler: () -> Void
        
        internal init(selectionHandler: @escaping (() -> Void)) {
            self.selectionHandler = selectionHandler
        }
        
        @objc internal func invokeSelectionHandler() {
            selectionHandler()
        }
        
    }
    
    private struct AssociatedKeys {
        internal static var selectionHandlerWrapper = "selectionHandlerWrapper"
    }
    
}
