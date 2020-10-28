//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A style of form elements in which a value can be entered.
/// :nodoc:
public protocol FormValueItemStyle: TintableStyle {
    
    /// The color of bottom line separating form elements.
    var separatorColor: UIColor? { get }
    
}

/// An item in a form in which a value can be entered.
/// :nodoc:
public protocol FormValueItem: FormItem {
    
    /// The type of value entered in the item.
    associatedtype ValueType
    
    associatedtype StyleType: FormValueItemStyle
    
    /// The value entered in the item.
    var value: ValueType { get set }
    
    /// The style of  form item view.
    var style: StyleType { get }
    
    /// An empty method that provides an opportunity for subclasses to know when the value changed.
    func valueDidChange()
    
}

extension FormValueItem {
    /// :nodoc:
    public func valueDidChange() {}
}
