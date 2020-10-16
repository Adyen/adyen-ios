//
//  File.swift
//  
//
//  Created by Mohamed Eldoheiri on 10/16/20.
//

import Foundation

/// This is excluded from the Swift Package, since swift packages has different code to access internal resources.
/// The Bundle extension in `BundleSPMExtension.swift` is used instead.
internal extension Bundle {
    // swiftlint:disable explicit_acl

    /// The main bundle of the framework.
    static let core: Bundle = {
        Bundle(for: Coder.self)
    }()

    /// The bundle in which the framework's resources are located.
    static let internalResources: Bundle = {
        let url = core.url(forResource: "Adyen", withExtension: "bundle")
        let bundle = url.flatMap { Bundle(url: $0) }
        return bundle ?? core
    }()

    // swiftlint:enable explicit_acl
}
