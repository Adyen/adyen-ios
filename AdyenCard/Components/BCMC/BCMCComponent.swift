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
    ///   - apiContext: The API context.
    ///   - configuration: The configuration of the component.
    ///   - addressViewModelBuilder: The address viewmodel builder of the component.
    public init(paymentMethod: BCMCPaymentMethod,
                apiContext: APIContext,
                configuration: CardComponent.Configuration = .init(),
                addressViewModelBuilder: AddressViewModelBuilder) {
        let configuration = configuration.bcmcConfiguration()
        
        let publicKeyProvider = PublicKeyProvider(apiContext: apiContext)
        let binInfoProvider = BinInfoProvider(apiClient: APIClient(apiContext: apiContext),
                                              publicKeyProvider: publicKeyProvider,
                                              minBinLength: Constant.privateBinLength)
        super.init(paymentMethod: paymentMethod,
                   apiContext: apiContext,
                   configuration: configuration,
                   publicKeyProvider: publicKeyProvider,
                   binProvider: binInfoProvider,
                   addressViewModelBuilder: addressViewModelBuilder)
    }

}
