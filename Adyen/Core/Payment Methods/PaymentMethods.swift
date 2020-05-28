//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A collection of available payment methods.
public struct PaymentMethods: Decodable {
    
    /// The regular payment methods.
    public let regular: [PaymentMethod]
    
    /// The stored payment methods.
    public let stored: [StoredPaymentMethod]
    
    /// Initializes the PaymentMethods.
    ///
    /// - Parameters:
    ///   - regular: An array of the regular payment methods.
    ///   - stored: An array of the stored payment methods.
    public init(regular: [PaymentMethod], stored: [StoredPaymentMethod]) {
        self.regular = regular
        self.stored = stored
    }
    
    /// Returns the first available payment method of the given type.
    ///
    /// - Parameter type: The type of payment method to retrieve.
    /// - Returns: The first available payment method of the given type, or `nil` if none could be found.
    public func paymentMethod<T: PaymentMethod>(ofType type: T.Type) -> T? {
        return regular.first { $0 is T } as? T
    }
    
    // MARK: - Decoding
    
    /// :nodoc:
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.regular = try container.decode([AnyPaymentMethod].self, forKey: .regular).compactMap { $0.value }
        
        if container.contains(.stored) {
            self.stored = try container.decode([AnyPaymentMethod].self, forKey: .stored).compactMap { $0.value as? StoredPaymentMethod }
        } else {
            self.stored = []
        }
    }
    
    internal enum CodingKeys: String, CodingKey {
        case regular = "paymentMethods"
        case stored = "storedPaymentMethods"
    }
    
}

internal enum AnyPaymentMethod: Decodable {
    case storedCard(StoredCardPaymentMethod)
    case storedPayPal(StoredPayPalPaymentMethod)
    case storedBCMC(StoredBCMCPaymentMethod)
    case storedRedirect(StoredRedirectPaymentMethod)
    
    case card(AnyCardPaymentMethod)
    case issuerList(IssuerListPaymentMethod)
    case sepaDirectDebit(SEPADirectDebitPaymentMethod)
    case redirect(RedirectPaymentMethod)
    case applePay(ApplePayPaymentMethod)
    case qiwiWallet(QiwiWalletPaymentMethod)
    case weChatPay(WeChatPayPaymentMethod)
    
    case none
    
    fileprivate var value: PaymentMethod? {
        switch self {
        case let .storedCard(paymentMethod):
            return paymentMethod
        case let .storedPayPal(paymentMethod):
            return paymentMethod
        case let .storedBCMC(paymentMethod):
            return paymentMethod
        case let .storedRedirect(paymentMethod):
            return paymentMethod
        case let .card(paymentMethod):
            return paymentMethod
        case let .issuerList(paymentMethod):
            return paymentMethod
        case let .sepaDirectDebit(paymentMethod):
            return paymentMethod
        case let .redirect(paymentMethod):
            return paymentMethod
        case let .applePay(paymentMethod):
            return paymentMethod
        case let .qiwiWallet(paymentMethod):
            return paymentMethod
        case let .weChatPay(paymentMethod):
            return paymentMethod
        case .none:
            return nil
        }
    }
    
    // MARK: - Decoding
    
    internal init(from decoder: Decoder) throws {
        self = AnyPaymentMethodDecoder.decode(from: decoder)
    }
    
    internal enum CodingKeys: String, CodingKey {
        case type
        case details
        case brand
    }
}
