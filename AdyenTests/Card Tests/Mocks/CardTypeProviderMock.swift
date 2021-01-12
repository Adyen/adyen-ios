//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

@testable import AdyenCard

final class CardTypeProviderMock: AnyCardBrandProvider {

    var onFetch: ((_ completion: @escaping ([CardBrand]) -> Void) -> Void)?

    func provide(for parameters: CardBrandProviderParameters, completion: @escaping ([CardBrand]) -> Void) {
        onFetch?(completion)
    }
}
