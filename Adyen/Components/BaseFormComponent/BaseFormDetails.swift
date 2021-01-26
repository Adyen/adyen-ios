//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// Contains the details supplied by the Base Form component.
public struct BaseFormDetails {

    /// The first Name.
    public let firstName: String?

    /// The last Name.
    public let lastName: String?

    /// The email address.
    public let emailAddress: String?

    /// The telephone number prefix.
    public let phonePrefix: String?

    /// The telephone number.
    public let phoneNumber: String?

    /// The telephone number.
    public var fullPhoneNumber: String? {
        guard let phoneNumber = phoneNumber, let phonePrefix = phonePrefix else {
            return nil
        }
        return phonePrefix + phoneNumber
    }

    /// Initializes the MB Way details.
    ///
    ///
    /// - Parameters:
    ///   - firstName: The first Name.
    ///   - lastName: The last Name.
    ///   - emailAddress: The email address.
    ///   - phonePrefix: The telephone number prefix.
    ///   - phoneNumber: The telephone number.
    public init(firstName: String? = nil,
                lastName: String? = nil,
                emailAddress: String? = nil,
                phonePrefix: String? = nil,
                phoneNumber: String? = nil) {
        self.firstName = firstName
        self.lastName = lastName
        self.emailAddress = emailAddress
        self.phonePrefix = phonePrefix
        self.phoneNumber = phoneNumber
    }

}
