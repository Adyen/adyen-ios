//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import Adyen3DS2
import Foundation
#if canImport(AdyenAuthentication)
    import AdyenAuthentication
#endif

extension ThreeDS2CompactActionHandler {
    
    /// Initializes the 3D Secure 2 action handler.
    internal convenience init(context: AdyenContext,
                              appearanceConfiguration: ADYAppearanceConfiguration,
                              delegatedAuthenticationConfiguration: ThreeDS2Component.Configuration.DelegatedAuthentication?) {
        
        let fingerprintSubmitter = ThreeDS2FingerprintSubmitter(apiContext: context.apiContext)
        self.init(
            context: context,
            fingerprintSubmitter: fingerprintSubmitter,
            appearanceConfiguration: appearanceConfiguration,
            coreActionHandler: createDefaultThreeDS2CoreActionHandler(
                context: context,
                appearanceConfiguration: appearanceConfiguration,
                delegatedAuthenticationConfiguration: delegatedAuthenticationConfiguration
            ),
            delegatedAuthenticationConfiguration: delegatedAuthenticationConfiguration
        )
    }
}
