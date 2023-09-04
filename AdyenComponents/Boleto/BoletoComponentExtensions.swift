//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

extension BoletoComponent {
    
    /// Boleto component configuration.
    public struct Configuration {
        /// Pre-filled optional personal information about the shopper
        let shopperInformation: PrefilledShopperInformation
        
        /// A Boleto payment method
        let boletoPaymentMethod: BoletoPaymentMethod
        
        /// The payment to be made
        let payment: Payment?
        
        /// Indicates whether to show `sendCopyByEmail` checkbox and email text field
        let showEmailAddress: Bool
        
        /// Initializes the configuration struct with shopper information
        /// - Parameters:
        ///   - boletoPaymentMethod: A Boleto payment method
        ///   - payment: The payment to be made
        ///   - shopperInformation: Pre-filled optional personal information about the shopper
        public init(boletoPaymentMethod: BoletoPaymentMethod,
                    payment: Payment?,
                    shopperInformation: PrefilledShopperInformation? = nil,
                    showEmailAddress: Bool) {
            self.boletoPaymentMethod = boletoPaymentMethod
            self.payment = payment
            self.shopperInformation = shopperInformation ?? PrefilledShopperInformation()
            self.showEmailAddress = showEmailAddress
        }
    }
    
}
