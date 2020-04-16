//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// The data supplied by a payment component upon completion.
public struct PaymentComponentData {
    
    /// The payment method details submitted by the payment component.
    public let paymentMethod: PaymentMethodDetails
    
    /// Indicates whether the user has chosen to store the payment method.
    public let storePaymentMethod: Bool
    
    /// Indicates the device default browser info.
    public let browserInfo: BrowserInfo?
    
    /// Initializes the payment component data.
    ///
    /// :nodoc:
    ///
    /// - Parameters:
    ///   - paymentMethodDetails: The payment method details submitted from the payment component.
    ///   - storePaymentMethod: Whether the user has chosen to store the payment method.
    ///   - browserInfo: The device default browser info.
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
