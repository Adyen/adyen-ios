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
public final class AffirmComponent: AbstractPersonalInformationComponent, Observer {
    
    private enum Content {
        static let personalDetailsTitle = "Personal details"
        static let deliveryAddressToggleTitle = "Seperate delivery address"
        static let deliveryAdddressTitle = "Delivery address"
        static let submitButtonTitle = "Confirm purchase"
    }
    
    // MARK: - Items
    
    private let deliveryAddressToggleItem: FormToggleItem
    private let deliveryAddressItem: FormAddressItem
    
    // MARK: - Properties
    
    private var isDeliveryAddressEnabled: Bool {
        return deliveryAddressToggleItem.value
    }
    
    // MARK: - Initializers
    
    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                style: FormComponentStyle) {
        let personalDetailsHeaderItem = FormLabelItem(text: Content.personalDetailsTitle, style: style.sectionHeader).addingDefaultMargins()
        deliveryAddressToggleItem = FormToggleItem(style: style.toggle)
        deliveryAddressItem = FormAddressItem(initialCountry: "US", title: Content.deliveryAdddressTitle, style: style.addressStyle)
        
        let fields: [PersonalInformation] = [.custom(CustomFormItemInjector(item: personalDetailsHeaderItem)),
                                             .firstName,
                                             .lastName,
                                             .email,
                                             .phone,
                                             .address,
                                             .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 16))),
                                             .custom(CustomFormItemInjector(item: deliveryAddressToggleItem)),
                                             .custom(CustomFormItemInjector(item: deliveryAddressItem)),
                                             .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 24)))]
        let configuration = Configuration(fields: fields)
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   apiContext: apiContext,
                   style: style)
        setup()
    }
    
    // MARK: - Private
    
    private func setup() {
        emailItem?.autocapitalizationType = .none
        setupDeliveryAddressToggleItem()
    }
    
    private func setupDeliveryAddressToggleItem() {
        deliveryAddressToggleItem.title = Content.deliveryAddressToggleTitle
        deliveryAddressToggleItem.value = false
        bind(deliveryAddressToggleItem.publisher, to: deliveryAddressItem, at: \.isHidden.wrappedValue, with: { !$0 })
    }
    
    // MARK: - Public
    
    public override func submitButtonTitle() -> String {
        return Content.submitButtonTitle
    }
    
    public override func createPaymentDetails() -> PaymentMethodDetails {
        let firstName = firstNameItem?.value
        let lastName = lastNameItem?.value
        let emailAddress = emailItem?.value
        let telephoneNumber = phoneItem?.value
        let billingAddress = addressItem?.value
        
        guard [firstName, lastName, emailAddress, telephoneNumber].allSatisfy({ $0 != nil }) else {
            fatalError()
        }
        guard let billingAddress = billingAddress else {
            fatalError()
        }
        
        let shopperName = ShopperName(firstName: firstName!, lastName: lastName!)
        let deliveryAddress = isDeliveryAddressEnabled ? deliveryAddressItem.value : billingAddress
        let affirmDetails = AffirmDetails(paymentMethod: paymentMethod,
                                          shopperName: shopperName,
                                          telephoneNumber: telephoneNumber!,
                                          emailAddress: emailAddress!,
                                          billingAddress: billingAddress,
                                          deliveryAddress: deliveryAddress)
        return affirmDetails
    }
    
    public override func getPhoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        return PhoneExtensionsRepository.get(with: query)
    }
}
