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
        static let deliveryAddressToggleTitle = "Seperate delivery address"
    }
    
    // MARK: - Items
    
    private let personalDetailsHeaderItem: FormLabelItem
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
        personalDetailsHeaderItem = FormLabelItem(text: "", style: style.sectionHeader)
        deliveryAddressToggleItem = FormToggleItem(style: style.toggle)
        deliveryAddressItem = FormAddressItem(initialCountry: Locale.current.regionCode ?? "US", style: style.addressStyle)
        
        let fields: [PersonalInformation] = [.custom(CustomFormItemInjector(item: personalDetailsHeaderItem.addingDefaultMargins())),
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
        setupItems()
    }
    
    // MARK: - Private
    
    private func setupItems() {
        personalDetailsHeaderItem.text = localizedString(.boletoPersonalDetails, localizationParameters)
        emailItem?.autocapitalizationType = .none
        deliveryAddressItem.title = localizedString(.deliveryAddressSectionTitle, localizationParameters)
        setupDeliveryAddressToggleItem()
    }
    
    private func setupDeliveryAddressToggleItem() {
        deliveryAddressToggleItem.title = localizedString(.deliveryAddressSectionTitle, localizationParameters)
        deliveryAddressToggleItem.value = false
        bind(deliveryAddressToggleItem.publisher, to: deliveryAddressItem, at: \.isHidden.wrappedValue, with: { !$0 })
    }
    
    // MARK: - Public
    
    public override func submitButtonTitle() -> String {
        return localizedString(.confirmPurchase, localizationParameters)
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
