//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(AdyenUI)
    import AdyenUI
    @_spi(AdyenInternal) import class AdyenUI.FormViewController
#endif
import Foundation

/// Builds a `FormItem` and injects it into a `FormViewController`.
package protocol FormItemInjector {

    func inject(into formViewController: FormViewController)
    
}

/// Injects a custom `FormItem` into a `FormViewController`.
package struct CustomFormItemInjector<T: FormItem>: FormItemInjector {

    private let item: T
    
    /// Initializes a `CustomFormItemInjector` with a custom `FormItem`
    /// - Parameter item: `FormItem` to be injected
    package init(item: T) {
        self.item = item
    }
    
    package func inject(into formViewController: FormViewController) {
        formViewController.append(item)
    }
    
}
