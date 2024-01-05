//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen

extension FormVerticalStackItemView<FormAddressItem> {
    
    /// Returns true if all validatable items are valid
    var isValid: Bool {
        return flatSubitemViews.compactMap { $0 as? AnyFormValidatableValueItemView }.allSatisfy(\.isValid)
    }
}
