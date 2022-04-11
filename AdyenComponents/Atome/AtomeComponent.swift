//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

/// A component that provides a form for Atome payment.
public final class AtomeComponent: AbstractPersonalInformationComponent {

    /// Configuration for Atome Component
    public typealias Configuration = PersonalInformationConfiguration

    private enum ViewIdentifier {
        static let billingAddress = "billingAddressItem"
    }

    // MARK: - Items

    /// :nodoc:
    private let personalDetailsHeaderItem: FormLabelItem

    // MARK: - Initializers

    /// Initializes the Atome component.
    /// - Parameters:
    ///   - paymentMethod: The Atome payment method.
    ///   - apiContext: The component's API context.
    ///   - configuration: The component's configuration.
    public init(paymentMethod: PaymentMethod,
                apiContext: APIContext,
                configuration: Configuration = .init()) {
        personalDetailsHeaderItem = FormLabelItem(text: "", style: configuration.style.sectionHeader)

        let fields: [PersonalInformation] = [
            .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 2))),
            .custom(CustomFormItemInjector(item: personalDetailsHeaderItem.addingDefaultMargins())),
            .firstName,
            .lastName,
            .phone,
            .address,
            .custom(CustomFormItemInjector(item: FormSpacerItem(numberOfSpaces: 1)))
        ]

        super.init(paymentMethod: paymentMethod,
                   apiContext: apiContext,
                   fields: fields,
                   configuration: configuration)

        setupItems()
    }

    // MARK: - Private

    /// :nodoc:
    private func setupItems() {
        personalDetailsHeaderItem.text = localizedString(.boletoPersonalDetails, configuration.localizationParameters)
        phoneItem?.title =  localizedString(.phoneNumberTitle, configuration.localizationParameters)
    }

    // MARK: - Public

    /// :nodoc:
    override public func submitButtonTitle() -> String {
        localizedString(.continueTitle, configuration.localizationParameters)
    }

    /// :nodoc:
    override public func createPaymentDetails() throws -> PaymentMethodDetails {
        guard let firstName = firstNameItem?.value,
              let lastName = lastNameItem?.value,
              let telephoneNumber = phoneItem?.value,
              let billingAddress = addressItem?.value else {
                  throw UnknownError(errorDescription: "There seems to be an error in the BasicPersonalInfoFormComponent configuration")
        }

        let shopperName = ShopperName(firstName: firstName, lastName: lastName)
        let atomeDetails = AtomeDetails(paymentMethod: paymentMethod,
                                          shopperName: shopperName,
                                          telephoneNumber: telephoneNumber,
                                          billingAddress: billingAddress)
        return atomeDetails
    }

    /// :nodoc:
    override public func phoneExtensions() -> [PhoneExtension] {
        let query = PhoneExtensionsQuery(paymentMethod: .generic)
        return PhoneExtensionsRepository.get(with: query)
    }
    
    /// :nodoc:
    override public func addressViewModelBuilder() -> AddressViewModelBuilder {
        return AtomeAddressViewModelBuilder()
    }

}
