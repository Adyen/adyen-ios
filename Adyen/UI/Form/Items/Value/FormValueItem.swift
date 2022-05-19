//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// A style of form elements in which a value can be entered.
public protocol FormValueItemStyle: TintableStyle {
    
    /// The color of bottom line separating form elements.
    var separatorColor: UIColor? { get }

    /// The style of title label.
    var title: TextStyle { get }
    
}

/// An item in a form in which a value can be entered.
@_spi(AdyenInternal)
open class FormValueItem<ValueType: Equatable, StyleType: FormValueItemStyle>: FormItem {

    public private(set) var subitems: [FormItem]

    public var identifier: String?

    /// The value entered in the item.
    public var value: ValueType {
        get { publisher.wrappedValue }
        set { publisher.wrappedValue = newValue }
    }

    /// The publisher for value change updates.
    public var publisher: AdyenObservable<ValueType>

    /// The style of  form item view.
    public var style: StyleType

    /// The title of the item.
    @AdyenObservable(nil) public var title: String?

    /// Create new instance of FormValueItem
    internal init(value: ValueType, style: StyleType) {
        self.publisher = AdyenObservable(value)
        self.style = style
        self.subitems = []
    }

    open func build(with builder: FormItemViewBuilder) -> AnyFormItemView {
        fatalError("This is an abstract class that needs to be subclassed.")
    }

}
