//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// This is excluded from the Swift Package, since swift packages has different code to access internal resources.
/// The Bundle extension in `BundleSPMExtension.swift` is used instead.
/// :nodoc:
extension Bundle {

    /// The main bundle of the framework.
    internal static let actions: Bundle = .init(for: RedirectComponent.self)

    /// The bundle in which the framework's resources are located.
    internal static let actionsInternalResources: Bundle = {
        let url = actions.url(forResource: "AdyenActions", withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        return bundle ?? actions
    }()

}
