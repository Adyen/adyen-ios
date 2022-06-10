//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) @testable import Adyen
import XCTest

extension XCTestCase {
            
    internal func fill(addressView: FormVerticalStackItemView<FormAddressItem>, with address: PostalAddress) {
        let addressViewIdentifier = addressView.item.identifier?.components(separatedBy: ".").last ?? ""
        
        let cityItemView = addressView.findView(by: identifier(for: .city, addressView: addressViewIdentifier)) as? FormTextInputItemView
        populate(textItemView: cityItemView, with: address.city ?? "")
        
        let countryItemView = addressView.findView(by: identifier(for: .country, addressView: addressViewIdentifier)) as? FormTextInputItemView
        populate(textItemView: countryItemView, with: address.country ?? "")
        
        let houseNumberItemView = addressView.findView(by: identifier(for: .houseNumberOrName, addressView: addressViewIdentifier)) as? FormTextInputItemView
        populate(textItemView: houseNumberItemView, with: address.houseNumberOrName ?? "")
        
        let postalCodeItemView = addressView.findView(by: identifier(for: .postalCode, addressView: addressViewIdentifier)) as? FormTextInputItemView
        populate(textItemView: postalCodeItemView, with: address.postalCode ?? "")
        
        if let regionPickerView = addressView.findView(by: identifier(for: .stateOrProvince, addressView: addressViewIdentifier)) as? FormRegionPickerItemView,
           let selectedRow = regionPickerView.item.selectableValues.firstIndex(where: { $0.identifier == address.stateOrProvince ?? "" }) {
            regionPickerView.pickerView(regionPickerView.pickerView, didSelectRow: selectedRow, inComponent: 0)
        }
        
        let streetItemView = addressView.findView(by: identifier(for: .street, addressView: addressViewIdentifier)) as? FormTextInputItemView
        populate(textItemView: streetItemView, with: address.street ?? "")
        
        let apartmentItemView = addressView.findView(by: identifier(for: .apartment, addressView: addressViewIdentifier)) as? FormTextInputItemView
        populate(textItemView: apartmentItemView, with: address.apartment ?? "")
    }
    
    // MARK: - Private
    
    private func identifier(for field: AddressField, addressView: String) -> String {
        "\(addressView).\(field.rawValue)"
    }
}
