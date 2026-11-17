//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard

final class BinInfoProviderMock: AnyBinInfoProvider {
    func provide(for bin: String, supportedTypes: [CardBrand], completion: @escaping (BinLookupResponse) -> Void) {
        receivedSupportedTypes = supportedTypes
        onFetch?(completion)
    }

    var receivedSupportedTypes: [CardBrand]?

    var onFetch: ((_ completion: @escaping (BinLookupResponse) -> Void) -> Void)?

}
