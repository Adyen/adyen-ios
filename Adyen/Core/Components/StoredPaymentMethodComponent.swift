//
// Copyright (c) 2019 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

// TODO: Fix Stored PM UI
///  A component that handle stored payment methods.
@MainActor
package final class StoredPaymentMethodComponent: StoredPaymentComponent, Localizable {

    package var localizationParameters: LocalizationParameters?

    /// The context object for this component.
    package let context: AdyenContext

    /// The stored payment method.
    package var paymentMethod: PaymentMethod {
        storedPaymentMethod
    }

    package let type: PaymentComponentType = .stored
    package let requiresUserInteraction: Bool = false

    package weak var delegate: PaymentComponentDelegate?

    /// Initializes new instance of `StoredPaymentMethodComponent`.
    ///
    /// - Parameters:
    ///   - paymentMethod: The stored payment method.
    ///   - context: The context object.
    package init(
        paymentMethod: StoredPaymentMethod,
        context: AdyenContext
    ) {
        self.storedPaymentMethod = paymentMethod
        self.context = context
    }
    
    private let storedPaymentMethod: StoredPaymentMethod
    private var didSendInitialAnalytics = false

    package func performSubmit() {
        sendInitialAnalyticsIfNeeded()
        let details = StoredPaymentDetails(paymentMethod: self.storedPaymentMethod)
        let data = PaymentComponentData(
            paymentMethodDetails: details,
            order: self.order
        )
        submit(data: data)
    }

    // MARK: - PaymentComponent

    package lazy var viewController = UIViewController()

    private func sendInitialAnalyticsIfNeeded() {
        guard !didSendInitialAnalytics else { return }
        didSendInitialAnalytics = true
        sendInitialAnalytics()
    }

}

extension StoredPaymentMethodComponent: TrackableComponent {}

/// Store payment method details.
public struct StoredPaymentDetails: PaymentMethodDetails {
    
    @_spi(AdyenInternal)
    public var checkoutAttemptId: String?
    
    /// An encoded string containing important SDK-specific data.
    /// It is recommended to pass this field to your server to ensure maximum performance and reliability.
    public var sdkData: String?
    
    internal let type: PaymentMethodType
    
    internal let storedPaymentMethodIdentifier: String
    
    /// Initializes a new instance of `StoredPaymentDetails`
    ///
    /// - Parameter paymentMethod: The payment method.
    public init(paymentMethod: StoredPaymentMethod) {
        self.type = paymentMethod.type
        self.storedPaymentMethodIdentifier = paymentMethod.identifier
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case storedPaymentMethodIdentifier = "storedPaymentMethodId"
        case sdkData
    }
    
}
