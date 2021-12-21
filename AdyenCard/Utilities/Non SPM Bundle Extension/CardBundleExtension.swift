//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

/// This is excluded from the Swift Package, since swift packages has different code to access internal resources.
/// The Bundle extension in `BundleSPMExtension.swift` is used instead.
/// :nodoc:
extension Bundle {

    /// The main bundle of the framework.
    private static let cardBundle: Bundle = .init(for: CardComponent.self)

    /// The bundle in which the framework's resources are located.
    internal static var cardInternalResources: Bundle {
        let url = cardBundle.url(forResource: "AdyenCard", withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        return bundle ?? cardBundle
    }

}
