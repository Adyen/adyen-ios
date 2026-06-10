//
// Copyright (c) 2019 Adyen N.V.
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

    /// The payment method details submitted by the payment component.
    public let paymentMethod: PaymentMethodDetails
    
    /// Indicates whether the user has chosen to store the payment method.
    public let storePaymentMethod: Bool?

    /// The partial payment order if any.
    public let order: PartialPaymentOrder?
    
    /// The installments object.
    public let installments: Installments?
    
    /// Data applied via onBeforeSubmit callback. Takes priority for its fields.
    private var beforeSubmitData: BeforeSubmitData?
    
    /// Shopper name.
    public var shopperName: ShopperName? {
        beforeSubmitData?.shopperName ?? (paymentMethod as? ShopperInformation)?.shopperName
    }

    /// The email address.
    public var emailAddress: String? {
        beforeSubmitData?.shopperEmail ?? (paymentMethod as? ShopperInformation)?.emailAddress
    }

    /// The telephone number.
    public var telephoneNumber: String? {
        guard let shopperInfo = paymentMethod as? ShopperInformation else { return nil }
        return shopperInfo.telephoneNumber
    }
    
    /// Indicates the device default browser info.
    public let browserInfo: BrowserInfo?

    /// The billing address information.
    public var billingAddress: PostalAddress? {
        beforeSubmitData?.billingAddress ?? (paymentMethod as? ShopperInformation)?.billingAddress
    }
    
    /// The delivery address information.
    public var deliveryAddress: PostalAddress? {
        beforeSubmitData?.deliveryAddress ?? (paymentMethod as? ShopperInformation)?.deliveryAddress
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
    ///   - order: The partial payment order if any.
    ///   - storePaymentMethod: Whether the user has chosen to store the payment method.
    ///   - browserInfo: The device default browser info.
    ///   - checkoutAttemptId: The checkoutAttempt identifier.
    ///   - installments: Installments selection if specified.
    ///   - sdkData: The encoded SDK data if specified.
    package init(
        paymentMethodDetails: some PaymentMethodDetails,
        order: PartialPaymentOrder?,
        storePaymentMethod: Bool? = nil,
        browserInfo: BrowserInfo? = nil,
        installments: Installments? = nil
    ) {
        self.paymentMethod = paymentMethodDetails
        self.order = order
        self.storePaymentMethod = storePaymentMethod
        self.browserInfo = browserInfo
        self.installments = installments
    }
    
    internal func replacing(sdkData: SDKData) -> PaymentComponentData {
        var paymentMethodDetails = paymentMethod
        paymentMethodDetails.sdkData = sdkData.encodedValue
        return PaymentComponentData(
            paymentMethodDetails: paymentMethodDetails,
            order: order,
            storePaymentMethod: storePaymentMethod,
            browserInfo: browserInfo,
            installments: installments
        )
    }

    package func replacing(order: PartialPaymentOrder) -> PaymentComponentData {
        PaymentComponentData(
            paymentMethodDetails: paymentMethod,
            order: order,
            storePaymentMethod: storePaymentMethod,
            browserInfo: browserInfo,
            installments: installments
        )
    }

    package func replacing(checkoutAttemptId: String?) -> PaymentComponentData {
        guard let checkoutAttemptId else { return self }
        var paymentMethod = paymentMethod
        paymentMethod.checkoutAttemptId = checkoutAttemptId
        return PaymentComponentData(
            paymentMethodDetails: paymentMethod,
            order: order,
            storePaymentMethod: storePaymentMethod,
            browserInfo: browserInfo,
            installments: installments
        )
    }

    package func replacing(browserInfo: BrowserInfo?) -> PaymentComponentData {
        PaymentComponentData(
            paymentMethodDetails: paymentMethod,
            order: order,
            storePaymentMethod: storePaymentMethod,
            browserInfo: browserInfo,
            installments: installments
        )
    }

    package func replacing(beforeSubmitData: BeforeSubmitData) -> PaymentComponentData {
        var copy = self
        copy.beforeSubmitData = beforeSubmitData
        return copy
    }
}
