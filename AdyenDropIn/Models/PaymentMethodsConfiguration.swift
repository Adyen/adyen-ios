//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import PassKit

extension DropInComponent {
    
    /// Contains the configuration for the drop in component and the embedded payment method components.
    public final class PaymentMethodsConfiguration {
        
        /// Card component related configuration.
        public var card = CardConfiguration()
        
        public var applePay = ApplePayConfiguration()
        
        /// Initializes the drop in configuration.
        public init() {}
        
        /// Card component related configuration.
        public final class CardConfiguration {
            
            /// The public key used for encrypting card details.
            public var publicKey: String?
            
            /// Indicates if the field for entering the holder name should be displayed in the form. Defaults to false.
            public var showsHolderNameField = false
            
            /// Indicates if the field for storing the card payment method should be displayed in the form. Defaults to true.
            public var showsStorePaymentMethodField = true
            
        }
        
        public final class ApplePayConfiguration {
            
            /// The public key used for encrypting card details.
            public var summaryItems: [PKPaymentSummaryItem]?
            
            /// The merchant identifier for apple pay.
            public var merchantIdentifier: String?
            
        }
    }
}

public extension DropInComponent.PaymentMethodsConfiguration.CardConfiguration {
    
    /// :nodoc:
    @available(*, deprecated, renamed: "showsHolderNameField")
    var showsHolderName: Bool {
        set {
            showsHolderNameField = newValue
        }
        get {
            return showsHolderNameField
        }
    }
}
