//
// Copyright (c) 2021 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable @_spi(AdyenInternal) import AdyenCard

final class BinInfoProviderMock: AnyBinInfoProvider {
    func provide(for bin: String, supportedTypes: [CardType], completion: @escaping (BinLookupResponse) -> Void) {
        onFetch?(completion)
    }

    var onFetch: ((_ completion: @escaping (BinLookupResponse) -> Void) -> Void)?

}
