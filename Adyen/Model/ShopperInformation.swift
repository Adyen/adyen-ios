//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any object that holds shopper personal information, like first name, last name, email, and phone number.
public protocol ShopperInformation {

    /// Shopper name.
    var shopperName: ShopperName? { get }

    /// The email address.
    var emailAddress: String? { get }

    /// The telephone number.
    var telephoneNumber: String? { get }

}

/// Any object that holds shopper billing address information/
public protocol BillingAddressInformation {

    /// The billing address information.
    var billingAddress: PostalAddress? { get }

}

/// Shopper name.
public struct ShopperName: Codable {

    /// The first Name.
    public let firstName: String

    /// The last Name.
    public let lastName: String

    /// Initializes a `ShopperName` object.
    ///
    /// - Parameters:
    ///   - firstName: The first Name.
    ///   - lastName: The last Name.
    public init(firstName: String, lastName: String) {
        self.firstName = firstName
        self.lastName = lastName
    }
}
