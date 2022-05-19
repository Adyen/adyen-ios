//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
public protocol FormViewProtocol {
    
    func add<T: FormItem>(item: T?)
    
    func displayValidation()
}

@_spi(AdyenInternal)
extension FormViewController: FormViewProtocol {

    public func add<T: FormItem>(item: T?) {
        guard let item = item else { return }
        append(item)
    }

    public func displayValidation() {
        resignFirstResponder()
        showValidation()
    }
}
