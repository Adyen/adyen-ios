//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds a `FormItem` and injects it into a `FormViewController`.
/// :nodoc:
public protocol FormItemInjector {

    /// :nodoc:
    func inject(into formViewController: FormViewController)
    
}

/// Injects a custom `FormItem` into a `FormViewController`.
/// :nodoc:
public struct CustomFormItemInjector<T: FormItem>: FormItemInjector {
    
    /// :nodoc:
    private let item: T
    
    /// Initializes a `CustomFormItemInjector` with a custom `FormItem`
    /// - Parameter item: `FormItem` to be injected
    /// :nodoc:
    public init(item: T) {
        self.item = item
    }
    
    /// :nodoc:
    public func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
