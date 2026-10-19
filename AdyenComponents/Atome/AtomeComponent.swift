//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
@_spi(AdyenInternal) import struct Adyen.LocalizationKey

#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import UIKit

/// A component that provides a form for Atome payment.
package final class AtomeComponent: AbstractPersonalInformationComponent {

    /// Configuration for Atome Component
    package typealias Configuration = PersonalInformationConfiguration

    private enum ViewIdentifier {
        static let billingAddress = "billingAddressItem"
    }

    // MARK: - Items

    private let personalDetailsHeaderItem: FormLabelItem

    // MARK: - Initializers

    /// Initializes the Atome component.
    /// - Parameters:
    ///   - paymentMethod: The Atome payment method.
    ///   - context: The context object for this component.
    ///   - configuration: The component's configuration.
    package init(
        paymentMethod: PaymentMethod,
        context: AdyenContext,
        configuration: Configuration = .init()
    ) {
        personalDetailsHeaderItem = FormLabelItem(text: "", style: configuration.style.sectionHeader)

        let fields: [PersonalInformation] = [
            .firstName,
            .lastName,
            .phone,
            .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 2))),
            .address,
            .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 1)))
        ]

        super.init(
            paymentMethod: paymentMethod,
            context: context,
            fields: fields,
            configuration: configuration
        )

        setupItems()
    }

    // MARK: - Private

    private func setupItems() {
        personalDetailsHeaderItem.text = localizedString(.boletoPersonalDetails, configuration.localizationParameters)
        phoneItem?.title = localizedString(.phoneNumberTitle, configuration.localizationParameters)
    }

    override package func submitButtonTitle() -> String {
        localizedString(.continueTitle, configuration.localizationParameters)
    }

    override package func createPaymentDetails() throws -> PaymentMethodDetails {
        guard let firstName = firstNameItem?.value,
              let lastName = lastNameItem?.value,
              let telephoneNumber = phoneItem?.phoneNumber,
              let billingAddress = addressItem?.value else {
            throw UnknownError(errorDescription: "There seems to be an error in the BasicPersonalInfoFormComponent configuration")
        }

        let shopperName = ShopperName(firstName: firstName, lastName: lastName)
        return AtomeDetails(
            paymentMethod: paymentMethod,
            shopperName: shopperName,
            telephoneNumber: telephoneNumber,
            billingAddress: billingAddress
        )
    }

    override package func phoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        return PhoneExtensionsRepository.get(with: query)
    }

    override package func addressViewModelBuilder() -> AddressViewModelBuilder {
        AtomeAddressViewModelBuilder()
    }

}
