//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_documentation(visibility: internal)
public protocol FormViewProtocol {
    
    func add<T: FormItem>(item: T?)
    
    func displayValidation()
}

@_documentation(visibility: internal)
extension FormViewController: FormViewProtocol {

    public func add(item: (some FormItem)?) {
        guard let item else { return }
        append(item)
    }

    public func displayValidation() {
        resignFirstResponder()
        showValidation()
    }
}
