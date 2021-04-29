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
    var billingAddress: AddressInfo? { get }

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

/// The data supplied by a payment component upon completion.
public struct PaymentComponentData: ShopperInformation, BillingAddressInformation {
    
    /// The payment method details submitted by the payment component.
    public let paymentMethod: PaymentMethodDetails
    
    /// Indicates whether the user has chosen to store the payment method.
    public let storePaymentMethod: Bool

    /// Shopper name.
    public var shopperName: ShopperName? {
        guard let shopperInfo = paymentMethod as? ShopperInformation else { return nil }
        return shopperInfo.shopperName
    }

    /// The email address.
    public var emailAddress: String? {
        guard let shopperInfo = paymentMethod as? ShopperInformation else { return nil }
        return shopperInfo.emailAddress
    }

    /// The telephone number.
    public var telephoneNumber: String? {
        guard let shopperInfo = paymentMethod as? ShopperInformation else { return nil }
        return shopperInfo.telephoneNumber
    }
    
    /// Indicates the device default browser info.
    public let browserInfo: BrowserInfo?

    /// The billing address information.
    public var billingAddress: AddressInfo? {
        guard let shopperInfo = paymentMethod as? BillingAddressInformation else { return nil }
        return shopperInfo.billingAddress
    }
    
    /// Initializes the payment component data.
    ///
    /// :nodoc:
    ///
    /// - Parameters:
    ///   - paymentMethodDetails: The payment method details submitted from the payment component.
    ///   - storePaymentMethod: Whether the user has chosen to store the payment method.
    ///   - browserInfo: The device default browser info.
    ///   - addressInfo: The payment's billing address.
    public init(paymentMethodDetails: PaymentMethodDetails, storePaymentMethod: Bool = false, browserInfo: BrowserInfo? = nil) {
        self.paymentMethod = paymentMethodDetails
        self.storePaymentMethod = storePaymentMethod
        self.browserInfo = browserInfo
    }
    
    /// Creates a new `PaymentComponentData` by populating the `browserInfo`,
    /// in case the browser info like the user-agent is needed, but its not needed for mobile payments.
    ///
    /// - Parameters:
    ///   - completion: The completion closure that is called with the new `PaymentComponentData` instance.
    public func dataByAddingBrowserInfo(completion: @escaping ((_ newData: PaymentComponentData) -> Void)) {
        BrowserInfo.initialize {
            completion(PaymentComponentData(paymentMethodDetails: self.paymentMethod,
                                            storePaymentMethod: self.storePaymentMethod,
                                            browserInfo: $0))
        }
    }
    
}
