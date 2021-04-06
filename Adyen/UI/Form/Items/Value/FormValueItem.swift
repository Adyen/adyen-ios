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
open class FormValueItem<T: Equatable, StyleType: FormValueItemStyle>: FormItem {

    /// :nodoc:
    public var identifier: String?

    /// The value entered in the item.
    public var value: Observable<T>

    /// The style of  form item view.
    public var style: StyleType

    /// Create new instance of FormValueItem
    internal init(value: T, style: StyleType) {
        self.value = Observable(value)
        self.style = style
    }

    open func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        preconditionFailure("This is abstract method. Override it on high tier object")
    }

}
