//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that provides a form for Affirm payment.
public final class AffirmComponent: AbstractPersonalInformationComponent, Observer {
    
    // MARK: - Items
    
    private let personalDetailsHeaderItem: FormLabelItem
    private let deliveryAddressToggleItem: FormToggleItem
    private let deliveryAddressItem: FormAddressItem
    
    // MARK: - Properties
    
    private var isDeliveryAddressEnabled: Bool {
        return deliveryAddressToggleItem.value
    }
    
    // MARK: - Initializers
    
    /// Initializes the Affirm component.
    /// - Parameters:
    ///   - paymentMethod: The Affirm payment method.
    ///   - apiContext: The component's API context.
    ///   - style: The component's style.
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
    
    /// :nodoc:
    private func setupItems() {
        personalDetailsHeaderItem.text = localizedString(.boletoPersonalDetails, localizationParameters)
        emailItem?.autocapitalizationType = .none
        deliveryAddressItem.title = localizedString(.deliveryAddressSectionTitle, localizationParameters)
        setupDeliveryAddressToggleItem()
    }
    
    /// :nodoc:
    private func setupDeliveryAddressToggleItem() {
        deliveryAddressToggleItem.title = localizedString(.deliveryAddressToggleTitle, localizationParameters)
        deliveryAddressToggleItem.value = false
        bind(deliveryAddressToggleItem.publisher, to: deliveryAddressItem, at: \.isHidden.wrappedValue, with: { !$0 })
    }
    
    // MARK: - Public
    
    /// :nodoc:
    public override func submitButtonTitle() -> String {
        return localizedString(.confirmPurchase, localizationParameters)
    }
    
    /// :nodoc:
    public override func createPaymentDetails() -> PaymentMethodDetails {
        let firstName = firstNameItem?.value
        let lastName = lastNameItem?.value
        let emailAddress = emailItem?.value
        let telephoneNumber = phoneItem?.value
        let billingAddress = addressItem?.value
        
        guard [firstName, lastName, emailAddress, telephoneNumber].allSatisfy({ $0 != nil }) else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        guard let billingAddress = billingAddress else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
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
    
    /// :nodoc:
    public override func getPhoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        return PhoneExtensionsRepository.get(with: query)
    }
}
