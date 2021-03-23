//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation
import UIKit

/// Struct with helper functions to build logo URL's.
public final class LogoURLProvider {

    /// Indicates the image size
    public enum Size: String {

        /// Small icon.
        case small

        /// Medium icon.
        case medium

        /// Large icon.
        case large
    }
    
    /// Build the logo URL for a given Payment Method.
    ///
    /// - Parameter paymentMethod: The payment method that needs the logo.
    /// - Parameter environment: The environemnt to be used.
    /// - Returns: The URL for the payment method logo.
    public static func logoURL(for paymentMethod: PaymentMethod,
                               environment: Environment,
                               size: Size = .small) -> URL {
        logoURL(withName: paymentMethod.displayInformation.logoName,
                environment: environment,
                size: size)
    }
    
    /// Build the logo URL for a specific issuer from an issuer list payment method.
    ///
    /// - Parameter issuer: The issuer that needs the logo.
    /// - Parameter paymentMethod: The issuer payment method.
    /// - Parameter environment: The environemnt to be used.
    /// - Returns: The URL for the issuer logo.
    public static func logoURL(for issuer: IssuerListPaymentMethod.Issuer, paymentMethod: IssuerListPaymentMethod, environment: Environment) -> URL {
        LogoURLProvider.url(for: [paymentMethod.displayInformation.logoName, issuer.identifier], environment: environment)
    }
    
    /// Build the logo URL for a specific named resource.
    ///
    /// - Parameter name: The name of the resource.
    /// - Parameter environment: The environemnt to be used.
    /// - Returns: The URL for the named resource logo.
    public static func logoURL(withName name: String,
                               environment: Environment,
                               size: Size = .small) -> URL {
        LogoURLProvider.url(for: [name], environment: environment, size: size)
    }
    
    // MARK: - Private
    
    private init() {}
    
    private static func url(for paths: [String], environment: Environment, size: Size = .small) -> URL {
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
