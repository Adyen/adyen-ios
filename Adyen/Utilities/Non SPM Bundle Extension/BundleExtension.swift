//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// This is excluded from the Swift Package, since swift packages has different code to access internal resources.
/// The Bundle extension in `BundleSPMExtension.swift` is used instead.
extension Bundle {

    /// The main bundle of the framework.
    internal static let core: Bundle = {
        Bundle(for: Coder.self)
    }()

    /// The bundle in which the framework's resources are located.
    internal static let internalResources: Bundle = {
        internalBundle(withName: "Adyen", inBundle: core)
    }()

    /// :nodoc:
    public static func internalBundle(withName name: String, inBundle: Bundle) -> Bundle {
        let url = core.url(forResource: name, withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        return bundle ?? inBundle
    }
}
