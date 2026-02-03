//
// Copyright (c) Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@_spi(AdyenInternal) import Adyen
#if canImport(AdyenUI)
    @_spi(AdyenInternal) import AdyenUI
#endif
import Adyen3DS2
import Foundation

// MARK: - ThreeDS2ActionConfiguration

/// Configuration for 3D Secure 2 action handling.
public struct ThreeDS2ActionConfiguration: CheckoutComponentConfiguration {
    
    package var configurationType: CheckoutConfigurationType {
        .action(.threeDS2)
    }
    
    package var showsSubmitButton: Bool = false
    
    package var theme: AdyenTheme = .default
    
    package var localizationParameters: LocalizationParameters?
    
    /// `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges.
    public var requestorAppURL: URL?
    
    /// The configuration for Delegated Authentication.
    public var delegatedAuthentication: DelegatedAuthenticationConfiguration?
    
    /// ThreeDS2Component UI configuration.
    public var appearanceConfiguration: ADYAppearanceConfiguration
    
    /// Initializes a new instance.
    ///
    /// - Parameters:
    ///   - requestorAppURL: `threeDSRequestorAppURL` for protocol version 2.2.0 OOB challenges.
    ///   - delegatedAuthentication: The configuration for Delegated Authentication.
    ///   - appearanceConfiguration: ThreeDS2Component UI configuration.
    public init(
        requestorAppURL: URL? = nil,
        delegatedAuthentication: DelegatedAuthenticationConfiguration? = nil,
        appearanceConfiguration: ADYAppearanceConfiguration = .init()
    ) {
        self.requestorAppURL = requestorAppURL
        self.delegatedAuthentication = delegatedAuthentication
        self.appearanceConfiguration = appearanceConfiguration
    }
}

// MARK: - TwintActionConfiguration

/// Configuration for Twint action handling.
public struct TwintActionConfiguration: CheckoutComponentConfiguration {
    
    package var configurationType: CheckoutConfigurationType {
        .action(.twint)
    }
    
    package var showsSubmitButton: Bool = false
    
    package var theme: AdyenTheme = .default
    
    package var localizationParameters: LocalizationParameters?
    
    /// The callback app scheme invoked once the Twint app is done with the payment.
    ///
    /// - Important: This value is required to only provide the scheme,
    /// without a host/path/... (e.g. "my-app", not a url "my-app://...")
    public var callbackAppScheme: String
    
    /// The issuer number of the highest scheme you listed under `LSApplicationQueriesSchemes`.
    /// E.g. pass 39, if you listed all schemes from "twint-issuer1" up to and including "twint-issuer39".
    /// The value is clamped between 0 and 39.
    ///
    /// - Important: All apps above "twint-issuer39" will always be returned if one of these apps is installed.
    /// For this to work, `LSApplicationQueriesSchemes` must include "twint-extended".
    /// If you configure any `maxIssuerNumber` below 39, the result will always contain all apps above `maxIssuerNumber`
    /// up to and including 39, even if none of them are installed.
    /// Additionally, if the fetch fails and the cache is empty, none of these apps will be found when probing.
    public var maxIssuerNumber: Int
    
    /// Initializes a new instance.
    ///
    /// - Parameters:
    ///   - callbackAppScheme: The callback app scheme invoked once the Twint app is done with the payment.
    ///   - maxIssuerNumber: The issuer number of the highest scheme you listed under `LSApplicationQueriesSchemes`.
    ///
    /// - Important: The value of `callbackAppScheme` is required to only provide the scheme,
    /// without a host/path/... (e.g. "my-app", not a url "my-app://...")
    public init(
        callbackAppScheme: String,
        maxIssuerNumber: Int = .max
    ) {
        if !Self.isCallbackSchemeValid(callbackAppScheme) {
            AdyenAssertion.assertionFailure(message: "Format of provided callbackAppScheme '\(callbackAppScheme)' is incorrect.")
        }
        
        self.callbackAppScheme = callbackAppScheme
        self.maxIssuerNumber = maxIssuerNumber
    }
    
    private static func isCallbackSchemeValid(_ callbackAppScheme: String) -> Bool {
        if let url = URL(string: callbackAppScheme), url.scheme != nil {
            return false
        }
        return true
    }
}

// MARK: - DelegatedAuthenticationConfiguration

/// Configuration for Delegated Authentication in 3D Secure 2.
public struct DelegatedAuthenticationConfiguration {
    
    /// The relying party identifier that is used for PassKeys.
    /// See: https://developer.apple.com/documentation/xcode/supporting-associated-domains
    /// See: https://developer.apple.com/documentation/authenticationservices/public-private_key_authentication/supporting_passkeys
    public let relyingPartyIdentifier: String
    
    /// The localization parameters, leave it nil to use the default parameters.
    public let localizationParameters: LocalizationParameters?
    
    /// Initializes a new instance.
    ///
    /// - Parameters:
    ///   - relyingPartyIdentifier: The relying party identifier that is used for PassKeys.
    ///   - localizationParameters: The localization parameters, leave it nil to use the default parameters.
    public init(
        relyingPartyIdentifier: String,
        localizationParameters: LocalizationParameters? = nil
    ) {
        self.relyingPartyIdentifier = relyingPartyIdentifier
        self.localizationParameters = localizationParameters
    }
}
