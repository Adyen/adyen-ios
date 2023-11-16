//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal protocol CardViewControllerDelegate: AnyObject {
    
    func didSelectAddressPicker(lookupProvider: AddressLookupProvider?)
    
    func didSelectSubmitButton()

    func didChange(bin: String)
    
    func didChange(pan: String)

}
