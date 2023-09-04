//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
public protocol FormViewProtocol {
    /// :nodoc:
    func add<T: FormItem>(item: T?)
    /// :nodoc:
    func displayValidation()
}

/// :nodoc:
extension FormViewController: FormViewProtocol {
    /// :nodoc:
    public func add(item: (some FormItem)?) {
        guard let item else { return }
        append(item)
    }

    /// :nodoc:
    public func displayValidation() {
        resignFirstResponder()
        showValidation()
    }
}
