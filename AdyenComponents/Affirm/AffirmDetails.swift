//
//  AffirmDetails.swift
//  AdyenComponents
//
//  Created by Naufal Aros on 7/13/21.
//  Copyright © 2021 Adyen. All rights reserved.
//

import Adyen
import Foundation

/// Contains the details supplied by the Affirm component.
public struct AffirmDetails: PaymentMethodDetails {
    
    /// The payment method type.
    public let type: String
    
    /// Initializes the Affirm details.
    ///
    /// - Parameter paymentMethod: The Affirm payment method.
    public init(paymentMethod: PaymentMethod) {
        self.type = paymentMethod.type
    }
    
    // MARK: - Private
    
    private enum CodingKeys: String, CodingKey {
        case type
    }
}
