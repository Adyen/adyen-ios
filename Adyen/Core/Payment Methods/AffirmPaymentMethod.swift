//
//  AffirmPaymentMethod.swift
//  Adyen
//
//  Created by Naufal Aros on 7/6/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Foundation

/// Affirm payment method.
public struct AffirmPaymentMethod: PaymentMethod {
    
    /// :nodoc:
    public var type: String
    
    /// :nodoc:
    public var name: String
    
    /// Initializes the Affirm payment method.
    ///
    /// - Parameter type: The payment method type.
    /// - Parameter name: The payment method name.
    internal init(type: String, name: String) {
        self.type = type
        self.name = name
    }
    
    /// :nodoc:
    public func buildComponent(using builder: PaymentComponentBuilder) -> PaymentComponent? {
        builder.build(paymentMethod: self)
    }
    
    // MARK: - Private
    
    private enum CodingKeys: String, CodingKey {
        case type
        case name
    }
}
