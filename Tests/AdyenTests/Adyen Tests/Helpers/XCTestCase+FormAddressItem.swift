//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import XCTest
@testable import Adyen

extension XCTestCase {
        
    private enum PostalAddressIdentifier {
        static let city = "Adyen.FormAddressItem.city"
        static let country = "Adyen.FormAddressItem.country"
        static let houseNumberOrName = "Adyen.FormAddressItem.houseNumberOrName"
        static let postalCode = "Adyen.FormAddressItem.postalCode"
        static let stateOrProvince = "Adyen.FormAddressItem.stateOrProvince"
        static let street = "Adyen.FormAddressItem.street"
        static let apartment = "Adyen.FormAddressItem.apartment"
    }
    
    
    internal func fill(formAddressView: FormVerticalStackItemView<FormAddressItem>, with address: PostalAddress) {
        let cityItemView = formAddressView.findView(by: PostalAddressIdentifier.city) as? FormTextInputItemView
        populate(textItemView: cityItemView, with: address.city ?? "")
        
        let countryItemView = formAddressView.findView(by: PostalAddressIdentifier.country) as? FormTextInputItemView
        populate(textItemView: countryItemView, with: address.country ?? "")
        
        let houseNumberItemView = formAddressView.findView(by: PostalAddressIdentifier.houseNumberOrName) as? FormTextInputItemView
        populate(textItemView: houseNumberItemView, with: address.houseNumberOrName ?? "")
        
        let postalCodeItemView = formAddressView.findView(by: PostalAddressIdentifier.postalCode) as? FormTextInputItemView
        populate(textItemView: postalCodeItemView, with: address.postalCode ?? "")
        
        if let regionPickerView = formAddressView.findView(by: PostalAddressIdentifier.stateOrProvince) as? FormRegionPickerItemView,
           let selectedRow = regionPickerView.item.selectableValues.firstIndex(where: { $0.identifier == address.stateOrProvince ?? ""}) {
            regionPickerView.pickerView(regionPickerView.pickerView, didSelectRow: selectedRow, inComponent: 0)
        }
        
        let streetItemView = formAddressView.findView(by: PostalAddressIdentifier.street) as? FormTextInputItemView
        populate(textItemView: streetItemView, with: address.street ?? "")
        
        let apartmentItemView = formAddressView.findView(by: PostalAddressIdentifier.apartment) as? FormTextInputItemView
        populate(textItemView: apartmentItemView, with: address.apartment ?? "")
    }
}
