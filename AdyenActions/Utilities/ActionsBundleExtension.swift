//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

@_spi(AdyenInternal)
extension Bundle {

    /// The main bundle of the framework.
    internal static let actions: Bundle = .init(for: RedirectComponent.self)

    #if SWIFT_PACKAGE
        /// The bundle in which the framework's resources are located. This will be available when using swift packages.
        internal static let actionsInternalResources: Bundle = .module
    #else
        /// The bundle in which the framework's resources are located.
        internal static let actionsInternalResources: Bundle = {
            let url = actions.url(forResource: "AdyenActions", withExtension: "bundle")
            let bundle = url.flatMap { Bundle(url: $0) }
            return bundle ?? actions
        }()
    #endif

}
