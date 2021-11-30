//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public protocol FormViewProtocol {
    func add<T: FormItem>(item: T?)
    func displayValidation()
}

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
