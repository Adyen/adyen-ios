//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// A collection of available payment methods
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
    
    fileprivate enum CodingKeys: String, CodingKey {
        case regular = "paymentMethods"
        case stored = "storedPaymentMethods"
    }
    
}

private enum AnyPaymentMethod: Decodable {
    case storedCard(StoredCardPaymentMethod)
    case storedPayPal(StoredPayPalPaymentMethod)
    case storedRedirect(StoredRedirectPaymentMethod)
    
    case card(CardPaymentMethod)
    case issuerList(IssuerListPaymentMethod)
    case sepaDirectDebit(SEPADirectDebitPaymentMethod)
    case redirect(RedirectPaymentMethod)
    case applePay(ApplePayPaymentMethod)
    
    case none
    
    fileprivate var value: PaymentMethod? {
        switch self {
        case let .storedCard(paymentMethod):
            return paymentMethod
        case let .storedPayPal(paymentMethod):
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
        case .none:
            return nil
        }
    }
    
    // MARK: - Decoding
    
    fileprivate init(from decoder: Decoder) throws {
        do {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let type = try container.decode(String.self, forKey: .type)
            let isStored = decoder.codingPath.contains { $0.stringValue == PaymentMethods.CodingKeys.stored.stringValue }
            let requiresDetails = container.contains(.details)
            
            switch type {
            case "card", "scheme":
                if isStored {
                    self = .storedCard(try StoredCardPaymentMethod(from: decoder))
                } else {
                    self = .card(try CardPaymentMethod(from: decoder))
                }
            case "ideal", "entercash", "eps", "dotpay", "openbanking_UK", "molpay_ebanking_fpx_MY", "molpay_ebanking_TH", "molpay_ebanking_VN":
                self = .issuerList(try IssuerListPaymentMethod(from: decoder))
            case "sepadirectdebit":
                self = .sepaDirectDebit(try SEPADirectDebitPaymentMethod(from: decoder))
            case "applepay":
                self = .applePay(try ApplePayPaymentMethod(from: decoder))
            case "paypal":
                if isStored {
                    self = .storedPayPal(try StoredPayPalPaymentMethod(from: decoder))
                } else {
                    fallthrough
                }
            default:
                if isStored {
                    self = .storedRedirect(try StoredRedirectPaymentMethod(from: decoder))
                } else if !requiresDetails {
                    self = .redirect(try RedirectPaymentMethod(from: decoder))
                } else {
                    self = .none
                }
            }
        } catch {
            self = .none
        }
    }
    
    private enum CodingKeys: String, CodingKey {
        case type
        case details
    }
}
