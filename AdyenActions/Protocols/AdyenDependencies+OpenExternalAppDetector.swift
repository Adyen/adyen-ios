//
// Copyright (c) 2023 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Adyen

extension AdyenDependencyValues {
    var openAppDetector: OpenExternalAppDetector {
        get { Self[OpenExternalAppDetectorKey.self] }
        set { Self[OpenExternalAppDetectorKey.self] = newValue }
    }
}

internal struct OpenExternalAppDetectorKey: AdyenDependencyKey {
    static var currentValue: OpenExternalAppDetector = .live
}
