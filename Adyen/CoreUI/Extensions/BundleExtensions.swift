//
// Copyright (c) 2017 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension Bundle {
    
    /// The bundle in which the framework's resources are located.
    internal static let resources: Bundle = {
        let mainBundle = Bundle(for: PaymentRequest.self)
        
        // If we're installed through CocoaPods, there should be a CoreUI bundle with the resources.
        // If not, simply return the main bundle.
        guard
            let resourcesBundlePath = mainBundle.path(forResource: "CoreUI", ofType: "bundle"),
            let resourcesBundle = Bundle(path: resourcesBundlePath)
        else {
            return mainBundle
        }
        
        return resourcesBundle
    }()
    
}
