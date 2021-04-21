//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

/// This is excluded from the normal xcode project file,
/// and used only when built with Swift Package Manager,
/// since swift packages has different code to access internal resources,
/// that doesn't compile in a normal xcode project.
/// The Bundle extension in `BundleExtension.swift` is used instead.
internal extension Bundle {
    // swiftlint:disable explicit_acl

    /// The main bundle of the framework.
    static let core: Bundle = {
        Bundle(for: FormView.self)
    }()

    /// The bundle in which the framework's resources are located.
    static let coreInternalResources: Bundle = {
        Bundle.module
    }()

    // swiftlint:enable explicit_acl
}
