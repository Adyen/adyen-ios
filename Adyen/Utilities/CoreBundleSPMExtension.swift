//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

package extension Bundle {
    #if SWIFT_PACKAGE
        /// The bundle in which the framework's resources are located.
        /// This will be available when using swift packages, open the `Package.swift` file and see.
        package static let coreInternalResources: Bundle = .module
    #else
        static let coreBundle: Bundle = .init(for: AdyenContext.self)
        package static let coreInternalResources: Bundle = {
            let url = coreBundle.url(forResource: "Adyen", withExtension: "bundle")
            let bundle = url.flatMap { Bundle(url: $0) }
            return bundle ?? coreBundle
        }()
    #endif
}
