//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in a form in which a value can be entered.
/// :nodoc:
public protocol FormValueItem: FormItem {
    
    /// The type of value entered in the item.
    associatedtype ValueType
    
    /// The value entered in the item.
    var value: ValueType { get set }
    
}
