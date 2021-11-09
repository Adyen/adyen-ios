//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A structure that contains information about the shopper
public struct PrefilledShopperInformation: ShopperInformation {

    /// The name of the shopper.
    public var shopperName: ShopperName?
    
    /// The email address.
    public var emailAddress: String?
    
    /// The telephone number.
    public var telephoneNumber: String?
    
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
    public init(shopperName: ShopperName? = nil,
                emailAddress: String? = nil,
                telephoneNumber: String? = nil,
                billingAddress: PostalAddress? = nil,
                deliveryAddress: PostalAddress? = nil,
                socialSecurityNumber: String? = nil,
                card: CardInformation? = nil) {
        self.shopperName = shopperName
        self.emailAddress = emailAddress
        self.telephoneNumber = telephoneNumber
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
