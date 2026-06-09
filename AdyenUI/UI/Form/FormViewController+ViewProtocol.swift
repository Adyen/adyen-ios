//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package protocol FormViewProtocol {

    func add(item: (some FormItem)?)
    
    func displayValidation()
}

extension FormViewController: FormViewProtocol {

    package func add(item: (some FormItem)?) {
        guard let item else { return }
        append(item)
    }

    package func add(item: (any FormItem)?) {
        guard let item else { return }
        append(item)
    }

    package func displayValidation() {
        resignFirstResponder()
        showValidation()
    }
}
