//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation
import UIKit

/// A component that handles BCMC card payments.
public final class BCMCComponent: CardComponent {
    
    /// :nodoc:
    public init(paymentMethod: BCMCPaymentMethod,
                configuration: CardComponent.Configuration = CardComponent.Configuration(),
                clientKey: String,
                style: FormComponentStyle = FormComponentStyle()) {
        let configuration = configuration.bcmcConfiguration()
        super.init(paymentMethod: paymentMethod,
                   configuration: configuration,
                   cardPublicKeyProvider: CardPublicKeyProvider(),
                   clientKey: clientKey,
                   style: style)
    }

}
