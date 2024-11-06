//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The telephone number in E.123 international notation.
public struct PhoneNumber {

    /// The phone number excluding calling code
    public let value: String

    /// The country calling code in E.123 international notation (ex. +22).
    public let callingCode: String?

    public init(value: String, callingCode: String?) {
        self.value = value
        self.callingCode = callingCode
    }
}

/// A structure that contains information about the shopper
public struct PrefilledShopperInformation: ShopperInformation {

    /// The name of the shopper.
    public var shopperName: ShopperName?
    
    /// The email address.
    public var emailAddress: String?
    
    /// The telephone number.
    @available(*, deprecated, renamed: "phoneNumber")
    public var telephoneNumber: String?

    /// The phone number.
    public var phoneNumber: PhoneNumber?
    
    /// The billing address information.
    public var billingAddress: PostalAddress?
    
    /// The delivery address information.
    public var deliveryAddress: PostalAddress?
    
    /// The social security number
    public var socialSecurityNumber: String?

    /// The card information
    public var card: CardInformation?
    
    /// Initializes the ShopperInfo struct
    /// - Parameters:
    ///   - shopperName: The name of the shopper, optional.
    ///   - emailAddress: The email of the shopper, optional.
    ///   - telephoneNumber: The telephone number of the shopper, optional.
    ///   - billingAddress: The billing address of the shopper, optional.
    ///   - deliveryAddress: The delivery address of the shopper, optional.
    ///   - socialSecurityNumber: The social security number of the shopper, optional.
    ///   - card: Shopper's card basic information, optional.
    // swiftlint:disable:next line_length
    @available(*, deprecated, renamed: "init(shopperName:emailAddress:phoneNumber:billingAddress:deliveryAddress:socialSecurityNumber:card:)")
    public init(
        shopperName: ShopperName? = nil,
        emailAddress: String? = nil,
        telephoneNumber: String? = nil,
        billingAddress: PostalAddress? = nil,
        deliveryAddress: PostalAddress? = nil,
        socialSecurityNumber: String? = nil,
        card: CardInformation? = nil
    ) {
        self.shopperName = shopperName
        self.emailAddress = emailAddress
        self.telephoneNumber = telephoneNumber
        self.billingAddress = billingAddress
        self.deliveryAddress = deliveryAddress
        self.socialSecurityNumber = socialSecurityNumber
        self.card = card
    }

    /// Initializes the ShopperInfo struct
    /// - Parameters:
    ///   - shopperName: The name of the shopper, optional.
    ///   - emailAddress: The email of the shopper, optional.
    ///   - phoneNumber: The phone number of the shopper, optional.
    ///   - billingAddress: The billing address of the shopper, optional.
    ///   - deliveryAddress: The delivery address of the shopper, optional.
    ///   - socialSecurityNumber: The social security number of the shopper, optional.
    ///   - card: Shopper's card basic information, optional.
    public init(
        shopperName: ShopperName? = nil,
        emailAddress: String? = nil,
        phoneNumber: PhoneNumber? = nil,
        billingAddress: PostalAddress? = nil,
        deliveryAddress: PostalAddress? = nil,
        socialSecurityNumber: String? = nil,
        card: CardInformation? = nil
    ) {
        self.shopperName = shopperName
        self.emailAddress = emailAddress
        self.phoneNumber = phoneNumber
        self.billingAddress = billingAddress
        self.deliveryAddress = deliveryAddress
        self.socialSecurityNumber = socialSecurityNumber
        self.card = card
    }
}

extension PrefilledShopperInformation {

    /// A structure that defines the basic properties for the shopper's card.
    public struct CardInformation {

        /// The card's holder name.
        public let holderName: String

        /// Initializes and returns the card information structure.
        /// - Parameter holderName: The card's holdername.
        public init(holderName: String) {
            self.holderName = holderName
        }
    }
}
