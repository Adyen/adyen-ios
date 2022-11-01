//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/**
 The data supplied by a payment component upon completion.

 - SeeAlso:
 [API Reference](https://docs.adyen.com/api-explorer/#/CheckoutService/latest/post/payments__example_payments-klarna)
 */
public struct PaymentComponentData {

    internal let amount: Amount?
    
    /// The payment method details submitted by the payment component.
    public let paymentMethod: PaymentMethodDetails
    
    /// Indicates whether the user has chosen to store the payment method.
    public let storePaymentMethod: Bool?

    /// The partial payment order if any.
    public let order: PartialPaymentOrder?

    /// The payment amount.
    public var amountToPay: Amount? {
        order?.remainingAmount ?? amount
    }
    
    /// The installments object.
    public let installments: Installments?
    
    /// Indicates whether the current SDK version suports native redirect without glue pages.
    public let supportNativeRedirect: Bool = true

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

    /// A unique identifier for a checkout attempt.
    public var checkoutAttemptId: String? {
        paymentMethod.checkoutAttemptId
    }

    /// The billing address information.
    public var billingAddress: PostalAddress? {
        guard let shopperInfo = paymentMethod as? ShopperInformation else { return nil }
        return shopperInfo.billingAddress
    }
    
    /// The delivery address information.
    public var deliveryAddress: PostalAddress? {
        guard let shopperInfo = paymentMethod as? ShopperInformation else { return nil }
        return shopperInfo.deliveryAddress
    }
    
    /// The social security number.
    public var socialSecurityNumber: String? {
        guard let shopperInfo = paymentMethod as? ShopperInformation else { return nil }
        return shopperInfo.socialSecurityNumber
    }
    
    public var delegatedAuthenticationData: DelegatedAuthenticationData? {
        guard let paymentMethod = paymentMethod as? DelegatedAuthenticationAware else { return nil }
        return paymentMethod.delegatedAuthenticationData
    }
    
    /// Initializes the payment component data.
    ///
    ///
    /// - Parameters:
    ///   - paymentMethodDetails: The payment method details submitted from the payment component.
    ///   - amount: The payment amount.
    ///   - order: The partial payment order if any.
    ///   - storePaymentMethod: Whether the user has chosen to store the payment method.
    ///   - browserInfo: The device default browser info.
    ///   - checkoutAttemptId: The checkoutAttempt identifier.
    ///   - installments: Installments selection if specified.
    @_spi(AdyenInternal)
    public init(paymentMethodDetails: PaymentMethodDetails,
                amount: Amount?,
                order: PartialPaymentOrder?,
                storePaymentMethod: Bool? = nil,
                browserInfo: BrowserInfo? = nil,
                installments: Installments? = nil) {
        self.amount = amount
        self.paymentMethod = paymentMethodDetails
        self.order = order
        self.storePaymentMethod = storePaymentMethod
        self.browserInfo = browserInfo
        self.installments = installments
    }

    @_spi(AdyenInternal)
    public func replacing(order: PartialPaymentOrder) -> PaymentComponentData {
        PaymentComponentData(paymentMethodDetails: paymentMethod,
                             amount: amount,
                             order: order,
                             storePaymentMethod: storePaymentMethod,
                             browserInfo: browserInfo,
                             installments: installments)
    }

    @_spi(AdyenInternal)
    public func replacing(amount: Amount) -> PaymentComponentData {
        PaymentComponentData(paymentMethodDetails: paymentMethod,
                             amount: amount,
                             order: order,
                             storePaymentMethod: storePaymentMethod,
                             browserInfo: browserInfo,
                             installments: installments)
    }

    @_spi(AdyenInternal)
    public func replacing(checkoutAttemptId: String?) -> PaymentComponentData {
        guard let checkoutAttemptId = checkoutAttemptId else { return self }
        var paymentMethod = paymentMethod
        paymentMethod.checkoutAttemptId = checkoutAttemptId
        return PaymentComponentData(paymentMethodDetails: paymentMethod,
                                    amount: amount,
                                    order: order,
                                    storePaymentMethod: storePaymentMethod,
                                    browserInfo: browserInfo,
                                    installments: installments)
    }
    
    /// Creates a new `PaymentComponentData` by populating the `browserInfo`,
    /// in case the browser info like the user-agent is needed, but its not needed for mobile payments.
    ///
    /// - Parameters:
    ///   - completion: The completion closure that is called with the new `PaymentComponentData` instance.
    @_spi(AdyenInternal)
    public func dataByAddingBrowserInfo(completion: @escaping ((_ newData: PaymentComponentData) -> Void)) {
        BrowserInfo.initialize {
            completion(PaymentComponentData(paymentMethodDetails: paymentMethod,
                                            amount: amount,
                                            order: order,
                                            storePaymentMethod: storePaymentMethod,
                                            browserInfo: $0,
                                            installments: installments))
        }
    }
    
}
