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
    
    /// :nodoc:
    public init(paymentMethod: BCMCPaymentMethod,
                configuration: CardComponent.Configuration = CardComponent.Configuration(),
                apiContext: APIContext,
                adyenContext: AdyenContext,
                style: FormComponentStyle = FormComponentStyle()) {
        let configuration = configuration.bcmcConfiguration()
        
        let publicKeyProvider = PublicKeyProvider(apiContext: apiContext)
        let binInfoProvider = BinInfoProvider(apiClient: APIClient(apiContext: apiContext),
                                              publicKeyProvider: publicKeyProvider,
                                              minBinLength: Constant.privateBinLength)
        super.init(paymentMethod: paymentMethod,
                   apiContext: apiContext,
                   adyenContext: adyenContext,
                   configuration: configuration,
                   style: style,
                   publicKeyProvider: publicKeyProvider,
                   binProvider: binInfoProvider)
    }

}
