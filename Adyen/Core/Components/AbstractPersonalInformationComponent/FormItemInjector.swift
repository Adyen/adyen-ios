//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Builds a `FormItem` and injects it into a `FormViewController`.
@_spi(AdyenInternal)
public protocol FormItemInjector {

    func inject(into formViewController: FormViewController)
    
}

/// Injects a custom `FormItem` into a `FormViewController`.
@_spi(AdyenInternal)
public struct CustomFormItemInjector<T: FormItem>: FormItemInjector {
    
    private let item: T
    
    /// Initializes a `CustomFormItemInjector` with a custom `FormItem`
    /// - Parameter item: `FormItem` to be injected
    public init(item: T) {
        self.item = item
    }
    
    public func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
