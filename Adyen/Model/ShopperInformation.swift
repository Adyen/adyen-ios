//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Any object that holds shopper personal information.
public protocol ShopperInformation {

    /// Shopper name.
    var shopperName: ShopperName? { get }

    /// The email address.
    var emailAddress: String? { get }

    /// The telephone number.
    var telephoneNumber: String? { get }
    
    /// The billing address information.
    var billingAddress: PostalAddress? { get }
    
    /// The delivery address information.
    var deliveryAddress: PostalAddress? { get }
    
    /// The social security number information.
    var socialSecurityNumber: String? { get }

}

/// :nodoc:
public extension ShopperInformation {
    
    var shopperName: ShopperName? { nil }

    var emailAddress: String? { nil }

    var telephoneNumber: String? { nil }
    
    var billingAddress: PostalAddress? { nil }
    
    var deliveryAddress: PostalAddress? { nil }

    var socialSecurityNumber: String? { nil }
    
}

/// Shopper name.
public struct ShopperName: Codable, Equatable {
    
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
