//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import AdyenNetworking
import Foundation
import UIKit

/// A component that handles BCMC card payments.
public final class BCMCComponent: CardComponent {
    
    /// Initializes the BCMC Component.
    /// - Parameters:
    ///   - paymentMethod: BCMC payment method.
    ///   - adyenContext: The Adyen context.
    ///   - configuration: The configuration of the component.
    public init(paymentMethod: BCMCPaymentMethod,
                adyenContext: AdyenContext,
                configuration: CardComponent.Configuration = .init()) {
        let configuration = configuration.bcmcConfiguration()
        
        let publicKeyProvider = PublicKeyProvider(apiContext: adyenContext.apiContext)
        let binInfoProvider = BinInfoProvider(apiClient: APIClient(apiContext: adyenContext.apiContext),
                                              publicKeyProvider: publicKeyProvider,
                                              minBinLength: Constant.privateBinLength)
        super.init(paymentMethod: paymentMethod,
                   adyenContext: adyenContext,
                   configuration: configuration,
                   publicKeyProvider: publicKeyProvider,
                   binProvider: binInfoProvider)
    }

}
