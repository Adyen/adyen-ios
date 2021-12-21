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
    internal static let core: Bundle = .init(for: FormView.self)

    /// The bundle in which the framework's resources are located.
    internal static let coreInternalResources: Bundle = {
        let url = core.url(forResource: "Adyen", withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        return bundle ?? core
    }()

}
