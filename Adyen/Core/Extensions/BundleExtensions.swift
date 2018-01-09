//
// Copyright (c) 2018 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension Bundle {
    
    /// The main bundle of the framework.
    internal static let core: Bundle = {
        Bundle(for: PaymentRequest.self)
    }()
    
    /// The bundle in which the framework's resources are located.
    internal static let resources: Bundle = {
        subspec("CoreUI")
    }()
    
    /// Retrieves the bundle for a subspec of the framework with the given name.
    /// If no bundle is found for the subspec, the framework's main bundle is returned.
    ///
    /// - Parameter subspec: The name of the subspec for which to retrieve the bundle.
    /// - Returns: The bundle for the subspec with the given name, or the framework's main bundle.
    internal static func subspec(_ subspec: String) -> Bundle {
        let url = core.url(forResource: subspec, withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        
        return bundle ?? core
    }
    
}
