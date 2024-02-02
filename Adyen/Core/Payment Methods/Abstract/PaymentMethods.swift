//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/**
 A collection of available payment methods.

 - SeeAlso:
 [API Reference](https://docs.adyen.com/api-explorer/#/CheckoutService/latest/post/paymentMethods__section_resParams)
 */
public struct PaymentMethods: Codable {

    /// The already paid payment methods, in case of partial payments.
    public var paid: [PaymentMethod] = []
    
    /// The regular payment methods.
    public var regular: [PaymentMethod]
    
    /// The stored payment methods.
    public var stored: [StoredPaymentMethod]
    
    /// Initializes the PaymentMethods.
    ///
    /// - Parameters:
    ///   - regular: An array of the regular payment methods.
    ///   - stored: An array of the stored payment methods.
    public init(regular: [PaymentMethod], stored: [StoredPaymentMethod]) {
        self.regular = regular
        self.stored = stored
    }
    
    /// Override the title/subtitle of a stored payment method shown in DropIn
    ///
    /// - Parameters:
    ///   - type: The type of the stored payment method.
    ///   - displayInformation: The `displayInformation` to use instead of the default one.
    ///   - predicate: A closure that takes a `PaymentMethod` of the payment methods list as
    ///   its argument and returns a Boolean value indicating whether the
    ///   `PaymentMethod` is a match.
    public mutating func overrideDisplayInformation<T: PaymentMethod>(
        ofStoredPaymentMethod type: PaymentMethodType,
        with displayInformation: MerchantCustomDisplayInformation,
        where predicate: (T) -> Bool
    ) {
        for (index, paymentMethod) in stored.enumerated() where paymentMethod.type == type {
            guard let paymentMethod = paymentMethod as? T,
                  predicate(paymentMethod) else { continue }
            stored[index].merchantProvidedDisplayInformation = displayInformation
        }
    }
    
    /// Override the title/subtitle of a stored payment method shown in DropIn
    ///
    /// - Parameters:
    ///   - type: The type of the stored payment method.
    ///   - displayInformation: The `displayInformation` to use instead of the default one.
    public mutating func overrideDisplayInformation(
        ofStoredPaymentMethod type: PaymentMethodType,
        with displayInformation: MerchantCustomDisplayInformation
    ) {
        for (index, paymentMethod) in stored.enumerated() where paymentMethod.type == type {
            stored[index].merchantProvidedDisplayInformation = displayInformation
        }
    }
    
    /// Override the title/subtitle of any payment method shown in DropIn
    ///
    /// - Parameters:
    ///   - type: The type of the payment method.
    ///   - displayInformation: The `displayInformation` to use instead of the default one.
    ///   - predicate: A closure that takes a `PaymentMethod` of the payment methods list as
    ///   its argument and returns a Boolean value indicating whether the
    ///   `PaymentMethod` is a match.
    public mutating func overrideDisplayInformation<T: PaymentMethod>(
        ofRegularPaymentMethod type: PaymentMethodType,
        with displayInformation: MerchantCustomDisplayInformation,
        where predicate: (T) -> Bool
    ) {
        for (index, paymentMethod) in regular.enumerated() where paymentMethod.type == type {
            guard let paymentMethod = paymentMethod as? T,
                  predicate(paymentMethod) else { continue }
            regular[index].merchantProvidedDisplayInformation = displayInformation
        }
    }
    
    /// Override the title/subtitle of any payment method shown in DropIn
    ///
    /// - Parameters:
    ///   - type: The type of the payment method.
    ///   - displayInformation: The `displayInformation` to use instead of the default one.
    public mutating func overrideDisplayInformation(
        ofRegularPaymentMethod type: PaymentMethodType,
        with displayInformation: MerchantCustomDisplayInformation
    ) {
        for (index, paymentMethod) in regular.enumerated() where paymentMethod.type == type {
            regular[index].merchantProvidedDisplayInformation = displayInformation
        }
    }
    
    /// Returns the first available payment method of the given type.
    ///
    /// - Parameter type: The type of payment method to retrieve.
    /// - Returns: The first available payment method of the given type, or `nil` if none could be found.
    public func paymentMethod<T: PaymentMethod>(ofType type: T.Type) -> T? {
        regular.first { $0 is T } as? T
    }
    
    /// Returns the first available payment method of the given type and also passes the predicate closure.
    ///
    /// - Parameters:
    ///   - type: The type of payment method to retrieve.
    ///   - predicate: A closure that takes a `PaymentMethod` of the payment methods list as
    ///   its argument and returns a Boolean value indicating whether the
    ///   `PaymentMethod` is a match.
    /// - Returns: The first available payment method of the given type and passes the predicate closure, or `nil` if none could be found.
    public func paymentMethod<T: PaymentMethod>(ofType type: T.Type,
                                                where predicate: (T) -> Bool) -> T? {
        regular.compactMap { $0 as? T }.first(where: predicate)
    }
    
    /// Returns the first available payment method of the given `PaymentMethodType`.
    ///
    /// - Parameter type: The `PaymentMethodType` of payment method to retrieve.
    /// - Returns: The first available payment method of the given type, or `nil` if none could be found.
    public func paymentMethod(ofType type: PaymentMethodType) -> PaymentMethod? {
        regular.first { $0.type == type }
    }
    
    /// Returns the first available payment method of the given `PaymentMethodType` and passes the predicate closure.
    ///
    /// - Parameters:
    ///   - type: The `PaymentMethodType` of payment method to retrieve.
    ///   - predicate: A closure that takes a `PaymentMethod` of the payment methods list as
    ///   its argument and returns a Boolean value indicating whether the
    ///   `PaymentMethod` is a match.
    /// - Returns: The first available payment method of the given type and passes the predicate closure, or `nil` if none could be found.
    public func paymentMethod<T: PaymentMethod>(ofType type: PaymentMethodType,
                                                where predicate: (T) -> Bool) -> T? {
        regular.filter { $0.type == type }.compactMap { $0 as? T }.first(where: predicate)
    }
    
    // MARK: - Decoding
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.regular = try container.decode(
            [AnyPaymentMethod].self,
            forKey: .regular
        ).compactMap(\.value)
        
        self.stored = try container.decodeIfPresent(
            [AnyPaymentMethod].self,
            forKey: .stored
        )?.compactMap {
            $0.value as? StoredPaymentMethod
        } ?? []
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(
            regular.map(\.toAnyPaymentMethod),
            forKey: .regular
        )
        
        try container.encode(
            stored.map(\.toAnyPaymentMethod),
            forKey: .stored
        )
    }
    
    internal enum CodingKeys: String, CodingKey {
        case regular = "paymentMethods"
        case stored = "storedPaymentMethods"
    }
    
}
