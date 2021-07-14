//
//  AffirmComponent.swift
//  AdyenComponents
//
//  Created by Naufal Aros on 7/6/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
import Foundation
import UIKit

/// A component that provides a form for Affirm payment.
public final class AffirmComponent: AbstractPersonalInformationComponent {
    
    // MARK: - Properties
    
    // MARK: - Initializers
    
    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle) {
        // TODO: - Init logic
        // 1. Set configuration
        let personalDetailsHeaderItem = FormLabelItem(text: "Personal details", style: style.sectionHeader).addingDefaultMargins()
        
        let deliveryAddressItem = FormAddressItem(initialCountry: "US", style: style.addressStyle)
        deliveryAddressItem.title = "Delivery address"
        let fields: [PersonalInformation] = [.custom(CustomFormItemInjector(item: personalDetailsHeaderItem)),
                                             .firstName,
                                             .lastName,
                                             .email,
                                             .phone,
                                             .address,
                                             .custom(CustomFormItemInjector(item: deliveryAddressItem))]
        
        let configuration = Configuration(fields: fields)
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   apiContext: apiContext,
                   style: style)
    }
    
    // MARK: - Public
    
    public override func submitButtonTitle() -> String {
        return "Confirm purchase"
    }
    
    public override func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstNameItem = firstNameItem else {
            fatalError()
        }
        guard let lastNameItem = lastNameItem else {
            fatalError()
        }
        guard let emailItem = emailItem else {
            fatalError()
        }
        guard let phoneItem = phoneItem else {
            fatalError()
        }
        guard let addressItem = addressItem else {
            fatalError()
        }
        
        let shopperName = ShopperName(firstName: firstNameItem.value,
                                      lastName: lastNameItem.value)
        let emailAddress = emailItem.value
        let telephoneNumber = phoneItem.value
        let billingAddress = addressItem.value
        
        let affirmDetails = AffirmDetails(paymentMethod: paymentMethod,
                                          shopperName: shopperName,
                                          telephoneNumber: telephoneNumber,
                                          emailAddress: emailAddress,
                                          billingAddress: billingAddress,
                                          deliveryAddress: nil)
        return affirmDetails
    }
    
    public override func getPhoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        return PhoneExtensionsRepository.get(with: query)
    }
    
    // MARK: - Private
    
//    private static var fields: [PersonalInformation] {
//        return []
//    }
}
