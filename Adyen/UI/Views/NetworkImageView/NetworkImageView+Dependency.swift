//
// Copyright (c) 2024 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import Foundation

extension AdyenDependencyValues {
    internal var networkImageProviderType: AdyenNetworkImageProviding.Type {
        get { self[NetworkImageProvidingKey.self] }
        set { self[NetworkImageProvidingKey.self] = newValue }
    }
}

internal enum NetworkImageProvidingKey: AdyenDependencyKey {
    internal static let liveValue: AdyenNetworkImageProviding.Type = AdyenNetworkImageProvider.self
}
