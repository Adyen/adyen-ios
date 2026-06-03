//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension Bundle {
    #if SWIFT_PACKAGE
        /// The bundle in which the framework's resources are located.
        /// This will be available when using swift packages, open the `Package.swift` file and see.
        static let cardInternalResources: Bundle = .module
    #else
        static let cardBundle: Bundle = .init(for: CardComponent.self)
        static let cardInternalResources: Bundle = {
            let url = cardBundle.url(forResource: "AdyenCard", withExtension: "bundle")
            let bundle = url.flatMap { Bundle(url: $0) }
            return bundle ?? cardBundle
        }()
    #endif
}
