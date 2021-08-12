//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that provides a form for Affirm payment.
public final class AffirmComponent: AbstractPersonalInformationComponent, Observer {
    
    private enum ViewIdentifier {
        static let billingAddress = "billingAddressItem"
        static let deliveryAddress = "deliveryAddressItem"
        static let deliveryAddressToggle = "deliveryAddressToggleItem"
    }
    
    // MARK: - Items
    
    /// :nodoc:
    private let personalDetailsHeaderItem: FormLabelItem
    
    /// :nodoc:
    internal let deliveryAddressToggleItem: FormToggleItem
    
    /// :nodoc:
    internal let deliveryAddressItem: FormAddressItem
    
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
        
        let fields: [PersonalInformation] = [
            .custom(CustomFormItemInjector(item: personalDetailsHeaderItem.addingDefaultMargins())),
            .firstName,
            .lastName,
            .email,
            .phone,
            .address,
            .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 16))),
            .custom(CustomFormItemInjector(item: deliveryAddressToggleItem)),
            .custom(CustomFormItemInjector(item: deliveryAddressItem)),
            .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 24)))
        ]
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

        setupBillingAddressItem()
        setupDeliveryAddressItem()
        setupDeliveryAddressToggleItem()
    }
    
    /// :nodoc:
    private func setupBillingAddressItem() {
        addressItem?.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                              postfix: ViewIdentifier.billingAddress)
    }
    
    /// :nodoc:
    private func setupDeliveryAddressItem() {
        deliveryAddressItem.title = localizedString(.deliveryAddressSectionTitle, localizationParameters)
        deliveryAddressItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                                     postfix: ViewIdentifier.deliveryAddress)
    }
    
    /// :nodoc:
    private func setupDeliveryAddressToggleItem() {
        deliveryAddressToggleItem.title = localizedString(.affirmDeliveryAddressToggleTitle, localizationParameters)
        deliveryAddressToggleItem.value = false
        deliveryAddressToggleItem.identifier = ViewIdentifierBuilder.build(scopeInstance: self,
                                                                           postfix: ViewIdentifier.deliveryAddressToggle)
        bind(deliveryAddressToggleItem.publisher, to: deliveryAddressItem, at: \.isHidden.wrappedValue, with: { !$0 })
    }
    
    // MARK: - Public
    
    /// :nodoc:
    override public func submitButtonTitle() -> String {
        localizedString(.confirmPurchase, localizationParameters)
    }
    
    /// :nodoc:
    override public func createPaymentDetails() -> PaymentMethodDetails {
        guard let firstName = firstNameItem?.value,
              let lastName = lastNameItem?.value,
              let emailAddress = emailItem?.value,
              let telephoneNumber = phoneItem?.value,
              let billingAddress = addressItem?.value else {
            fatalError("There seems to be an error in the BasicPersonalInfoFormComponent configuration.")
        }
        
        let shopperName = ShopperName(firstName: firstName, lastName: lastName)
        let deliveryAddress = deliveryAddressToggleItem.value ? deliveryAddressItem.value : billingAddress
        let affirmDetails = AffirmDetails(paymentMethod: paymentMethod,
                                          shopperName: shopperName,
                                          telephoneNumber: telephoneNumber,
                                          emailAddress: emailAddress,
                                          billingAddress: billingAddress,
                                          deliveryAddress: deliveryAddress)
        return affirmDetails
    }
    
    /// :nodoc:
    override public func getPhoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        return PhoneExtensionsRepository.get(with: query)
    }
}
