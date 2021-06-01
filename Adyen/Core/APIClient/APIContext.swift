//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// :nodoc:
/// An object that needs an API context to retrieve internal resources
public protocol APIContextAware: AnyObject {
    
    /// :nodoc:
    /// The API context
    var apiContext: APIContext { get }
    
}

/// :nodoc:
/// An API context that defines parameters for retrieving internal resources
public protocol APIContext {
    
    /// :nodoc:
    /// The environment to retrieve internal resources from.
    var environment: AnyAPIEnvironment { get }
    
    /// :nodoc:
    /// The HTTP headers.
    var headers: [String: String] { get }
    
    /// :nodoc:
    /// The query parameters.
    var queryParameters: [URLQueryItem] { get }
    
    /// :nodoc:
    /// The client key.
    var clientKey: String { get }

}

/// Struct that defines API context for retrieving internal resources.
public struct APIContext: APIContext {
    
    /// :nodoc:
    public var queryParameters: [URLQueryItem] {
        [URLQueryItem(name: "clientKey", value: clientKey)]
    }
    
    /// :nodoc:
    public let headers: [String: String] = ["Content-Type": "application/json"]

    /// Environment to retrieve internal resources from.
    public let environment: AnyAPIEnvironment
    
    /// The client key that corresponds to the webservice user you will use for initiating the payment.
    /// See https://docs.adyen.com/user-management/client-side-authentication for more information.
    public let clientKey: String
    
    /// Initializes the APIContext
    /// - Parameters:
    ///   - environment: The environment to retrieve internal resources from.
    ///   - clientKey: The client key that corresponds to the webservice user you will use for initiating the payment.
    public init(environment: AnyAPIEnvironment, clientKey: String) {
        guard ClientKeyValidator().isValid(clientKey) else {
            fatalError("ClientKey is invalid.")
        }

        self.environment = environment
        self.clientKey = clientKey
    }
            
}
