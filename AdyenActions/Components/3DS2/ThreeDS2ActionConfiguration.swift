//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Adyen3DS2

/// Configuration for 3D Secure 2 action handling.
public struct ThreeDS2ActionConfiguration: CheckoutComponentConfiguration {
    
    package let componentType: CheckoutComponentType = .action(.threeDS2)
    
    package var showsSubmitButton: Bool // TODO: get rid of this
    
    package var theme: AdyenTheme
    
    package var localizationParameters: LocalizationParameters?
    
    package var localizationProvider: (any CheckoutLocalizationProvider)?

    package var redirectComponentStyle: RedirectComponentStyle?
    
    /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges.
    package var requestorAppURL: URL?
    
    /// The configuration for Delegated Authentication.
    package var delegatedAuthentication: DelegatedAuthentication?
    
    /// ThreeDS2Component UI configuration.
    package var appearanceConfiguration: ADYAppearanceConfiguration
    
    /// Configuration for Delegated Authentication in 3D Secure 2.
    public struct DelegatedAuthentication {
        
        /// The relying party identifier that is used for PassKeys.
        /// See: https://developer.apple.com/documentation/xcode/supporting-associated-domains
        /// See: https://developer.apple.com/documentation/authenticationservices/public-private_key_authentication/supporting_passkeys
        package let relyingPartyIdentifier: String
        
        /// The configuration for Delegated Authentication Component style.
        package var style: DelegatedAuthenticationComponentStyle
        
        /// The localization parameters, leave it nil to use the default parameters.
        package var localizationParameters: LocalizationParameters?
        
        /// Initializes a new instance.
        ///
        /// - Parameters:
        ///   - relyingPartyIdentifier: The relying party identifier that is used for PassKeys.
        public init(relyingPartyIdentifier: String) {
            self.relyingPartyIdentifier = relyingPartyIdentifier
            self.style = DelegatedAuthenticationComponentStyle()
        }
    }
    
    /// Initializes a new instance of ThreeDS2ActionConfiguration
    public init() {
        self.theme = .default
        self.showsSubmitButton = false
        self.appearanceConfiguration = .init()
    }
}

extension ThreeDS2ActionConfiguration {
    
    /// Sets the `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges.
    /// - Parameter requestorAppURL: The requestor app URL.
    /// - Returns: A modified copy of the configuration.
    public func requestorAppURL(_ requestorAppURL: URL) -> Self {
        var copy = self
        copy.requestorAppURL = requestorAppURL
        return copy
    }
    
    /// Sets the configuration for Delegated Authentication.
    /// - Parameter delegatedAuthentication: The delegated authentication configuration.
    /// - Returns: A modified copy of the configuration.
    public func delegatedAuthentication(_ delegatedAuthentication: DelegatedAuthentication) -> Self {
        var copy = self
        copy.delegatedAuthentication = delegatedAuthentication
        return copy
    }
}
