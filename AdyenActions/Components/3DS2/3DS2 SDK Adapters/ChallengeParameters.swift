//
// Copyright (c) 2025 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

#if canImport(Adyen3DS2)

import Foundation

internal struct ChallengeParameters {
    internal let challengeToken: ThreeDS2Component.ChallengeToken
    internal let threeDSRequestorAppURL: URL?
}

#endif
