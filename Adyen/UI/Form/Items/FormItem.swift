//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// An item in a form.
/// :nodoc:
public protocol FormItem: AnyObject {
    
    /// An identifier for the `FormItem`,
    /// that  is set to the `FormItemView.accessibilityIdentifier` when the corresponding `FormItemView` is created.
    var identifier: String? { get set }
}
