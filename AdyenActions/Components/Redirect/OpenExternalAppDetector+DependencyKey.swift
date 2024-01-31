//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen
import UIKit

extension AdyenDependencyValues {
    internal var openAppDetector: OpenExternalAppDetector {
        get { self[OpenExternalAppDetectorKey.self] }
        set { self[OpenExternalAppDetectorKey.self] = newValue }
    }
}

internal enum OpenExternalAppDetectorKey: AdyenDependencyKey {
    internal static let liveValue: OpenExternalAppDetector = UIApplication.shared
}
