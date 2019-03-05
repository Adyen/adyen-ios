//
// Copyright (c) 2019 Adyen B.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

public extension Bundle {
    /// The main bundle of the framework.
    internal static let core: Bundle = {
        Bundle(for: AmountFormatter.self)
    }()
    
    /// The bundle in which the framework's resources are located.
    static let resources: Bundle = {
        let url = core.url(forResource: "AdyenInternal", withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        return bundle ?? core
    }()
    
}
