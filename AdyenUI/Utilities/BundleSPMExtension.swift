//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

internal extension Bundle {
    static let adyenUI: Bundle = .init(for: FormButton.self)

    #if SWIFT_PACKAGE
        static let adyenUIInternalResources: Bundle = adyenUI
    #else
        internal static let adyenUIInternalResources: Bundle = {
            let url = adyenUI.url(forResource: "AdyenUI", withExtension: "bundle")
            let bundle = url.flatMap { Bundle(url: $0) }
            return bundle ?? adyenUI
        }()
    #endif
}
