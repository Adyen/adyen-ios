//
// Copyright (c) 2026 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import Foundation

extension AdyenDependencyValues {
    /// Whether the host app declares `NSPhotoLibraryAddUsageDescription`.
    internal var hasPhotoLibraryAddUsageDescription: Bool {
        get { self[PhotoLibraryAddUsageDescriptionKey.self] }
        set { self[PhotoLibraryAddUsageDescriptionKey.self] = newValue }
    }
}

internal enum PhotoLibraryAddUsageDescriptionKey: AdyenDependencyKey {
    internal static let liveValue: Bool = Bundle.main.object(
        forInfoDictionaryKey: "NSPhotoLibraryAddUsageDescription"
    ) != nil
}
