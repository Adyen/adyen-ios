//
// Copyright (c) 2022 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenNetworking
import Foundation
import UIKit

/// Struct with helper functions to build logo URL's.
public final class LogoURLProvider {

    private let environment: AnyAPIEnvironment

    /// Create new instance of LogoURLProvider.
    /// - Parameter environment: The environment to reach out for logos.
    public init(environment: AnyAPIEnvironment) {
        self.environment = environment
    }

    /// Build the logo URL for a specific named resource.
    ///
    /// - Parameter name: The name of the resource.
    /// - Returns: The URL for the named resource logo.
    public func logoURL(withName name: String, size: Size = .small) -> URL {
        url(for: [name], size: size)
    }

    // MARK: - Static Methods
    
    /// Build the logo URL for a specific issuer from an issuer list payment method.
    ///
    /// - Parameter issuer: The issuer that needs the logo.
    /// - Parameter localizedParameters: The localization parameters
    /// - Parameter paymentMethod: The issuer payment method.
    /// - Parameter environment: The environment to be used.
    /// - Returns: The URL for the issuer logo.
    public static func logoURL(for issuer: Issuer,
                               localizedParameters: LocalizationParameters?,
                               paymentMethod: IssuerListPaymentMethod,
                               environment: AnyAPIEnvironment) -> URL {
        LogoURLProvider(environment: environment)
            .url(for: [
                paymentMethod.displayInformation(using: localizedParameters).logoName,
                issuer.identifier
            ])
    }
    
    /// Build the logo URL for a specific named resource.
    ///
    /// - Parameter name: The name of the resource.
    /// - Parameter environment: The environment to be used.
    /// - Returns: The URL for the named resource logo.
    public static func logoURL(withName name: String,
                               environment: AnyAPIEnvironment,
                               size: Size = .small) -> URL {
        LogoURLProvider(environment: environment).url(for: [name], size: size)
    }
    
    // MARK: - Private

    private func url(for paths: [String], size: Size = .small) -> URL {
        let pathComponents = ["checkoutshopper", "images", "logos", size.rawValue] + paths
        let components = pathComponents.joined(separator: "/") + LogoURLProvider.logoPathSuffix
        
        return environment.baseURL.appendingPathComponent(components)
    }
    
    private static var logoPathSuffix: String {
        let scale = Int(UIScreen.main.scale)
        if scale > 1 {
            return "@\(scale)x.png"
        }
        
        return ".png"
    }
}

extension LogoURLProvider {

    /// Indicates the image size
    public enum Size: String {

        /// Small icon.
        case small

        /// Medium icon.
        case medium

        /// Large icon.
        case large
    }

}
