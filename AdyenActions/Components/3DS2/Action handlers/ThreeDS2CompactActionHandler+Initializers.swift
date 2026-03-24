//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
import AdyenUI
import Foundation
#if canImport(AdyenAuthentication)
    import AdyenAuthentication
#endif

extension ThreeDS2CompactActionHandler {
    
    /// Initializes the 3D Secure 2 action handler.
    internal convenience init(
        context: AdyenContext,
        service: ThreeDSService,
        theme: AdyenTheme,
        delegatedAuthenticationConfiguration: ThreeDS2ActionConfiguration.DelegatedAuthentication?
    ) {
        
        let fingerprintSubmitter = ThreeDS2FingerprintSubmitter(context: context)
        self.init(
            context: context,
            fingerprintSubmitter: fingerprintSubmitter,
            theme: theme,
            service: service,
            coreActionHandler: createDefaultThreeDS2CoreActionHandler(
                context: context,
                service: service,
                theme: theme,
                delegatedAuthenticationConfiguration: delegatedAuthenticationConfiguration
            ),
            delegatedAuthenticationConfiguration: delegatedAuthenticationConfiguration
        )
    }
}
