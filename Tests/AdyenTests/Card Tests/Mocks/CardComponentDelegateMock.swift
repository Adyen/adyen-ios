//
// Copyright (c) 2020 Adyen N.V.
//
// This file is open source and available under the MIT license. See the LICENSE file for more info.
//

import AdyenCard

internal class CardComponentDelegateMock: CardComponentDelegate {
    
    private let onBINDidChange: (String) -> Void
    private let onCardBrandChange: ([CardBrand]?) -> Void
    
    internal init(onBINDidChange: @escaping (String) -> Void,
                  onCardBrandChange: @escaping ([CardBrand]?) -> Void) {
        self.onBINDidChange = onBINDidChange
        self.onCardBrandChange = onCardBrandChange
    }
    
    func didChangeBIN(_ value: String, component: CardComponent) {
        onBINDidChange(value)
    }
    
    func didChangeCardBrand(_ value: [CardBrand]?, component: CardComponent) {
        onCardBrandChange(value)
    }
}
