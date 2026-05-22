//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension Bundle {

    /// The main bundle of the framework.
    internal static let core: Bundle = .init(for: AdyenContext.self)

    #if SWIFT_PACKAGE
        /// The bundle in which the framework's resources are located. This will be available when using swift packages.
        package static let coreInternalResources: Bundle = .module
    #else
        /// The bundle in which the framework's resources are located.
        package static let coreInternalResources: Bundle = {
            let url = core.url(forResource: "Adyen", withExtension: "bundle")
            let bundle = url.flatMap { Bundle(url: $0) }
            return bundle ?? core
        }()
    #endif

}
